# frozen_string_literal: true

class UpdateStatusService < BaseService
  include Redisable

  ALLOWED_ATTRIBUTES = %i(
    spoiler_text
    text
    content_type
    language
    sensitive
    visibility
    media_attachments
    media_attachment_ids
    application
    rate_limit
  ).freeze

  # Updates the content of an existing status.
  # @param [Status] status The status to update.
  # @param [Hash] params The attributes of the new status.
  # @param [Enumerable] mentions Additional mentions added to the status.
  # @param [Enumerable] tags New tags for the status to belong to (implicit tags are preserved).
  def call(status, params, mentions, tags)
    raise ActiveRecord::RecordNotFound if status.blank? || status.discarded? || status.destroyed?
    return status if params.blank?

    @status                 = status
    @account                = @status.account
    @params                 = params.with_indifferent_access.slice(*ALLOWED_ATTRIBUTES).compact
    @mentions               = (@status.mentions | (mentions || [])).to_set
    @tags                   = (tags.nil? ? @status.tags : (tags || [])).to_set

    @params[:text]        ||= ''
    @params[:edited]      ||= 1 + @status.edited

    update_tags if @status.local?
    filter_tags
    update_mentions

    @delete_payload         = Oj.dump(event: :delete, payload: @status.id.to_s)
    @deleted_tag_ids        = @status.tag_ids - @tags.pluck(:id)
    @deleted_tag_names      = @status.tags.pluck(:name) - @tags.pluck(:name)
    @deleted_attachment_ids = @status.media_attachment_ids - (@params[:media_attachment_ids] || @params[:media_attachments]&.pluck(:id) || [])
    @new_mention_ids        = @mentions.pluck(:id) - @status.mention_ids

    ApplicationRecord.transaction do
      @status.update!(@params)
      detach_deleted_tags
      attach_updated_tags
    end

    prune_tags
    prune_attachments
    reset_status_caches

    SpamCheck.perform(@status)
    distribute

    @status
  end

  private

  def prune_attachments
    RemoveMediaAttachmentsWorker.perform_async(@deleted_attachment_ids) if @deleted_attachment_ids.present?
  end

  def detach_deleted_tags
    @status.tags.where(id: @deleted_tag_ids).destroy_all if @deleted_tag_ids.present?
  end

  def prune_tags
    @account.featured_tags.where(tag_id: @deleted_tag_ids).each do |featured_tag|
      featured_tag.decrement(@status.id)
    end

    if @status.public_visibility?
      return if @deleted_tag_names.blank?

      @deleted_tag_names.each do |hashtag|
        redis.publish("timeline:hashtag:#{hashtag.mb_chars.downcase}", @delete_payload)
        redis.publish("timeline:hashtag:#{hashtag.mb_chars.downcase}:local", @delete_payload) if @status.local?
      end
    end
  end

  def update_tags
    old_explicit_tags = Tag.matching_name(Extractor.extract_hashtags(@status.text))
    @tags |= Tag.find_or_create_by_names(Extractor.extract_hashtags(@params[:text]))

    # Preserve implicit tags attached to the original status.
    # TODO: Let locals remove them from edits.
    @tags |= @status.tags.where.not(id: old_explicit_tags.select(:id))
  end

  def filter_tags
    @tags.select! { |tag| tag =~ /\A(#{Tag::HASHTAG_NAME_RE})\z/i }
  end

  def update_mentions
    @params[:text], @mentions = ResolveMentionsService.new.call(@status, text: @params[:text], mentions: @mentions)
  end

  def attach_updated_tags
    tag_ids = @status.tag_ids.to_set
    new_tag_ids = []
    now = Time.now.utc

    @tags.each do |tag|
      next if tag_ids.include?(tag.id) || /\A(#{Tag::HASHTAG_NAME_RE})\z/i =~ $LAST_READ_LINE

      @status.tags << tag
      new_tag_ids << tag.id
      TrendingTags.record_use!(tag, @account, now) if @status.public_visibility?
    end

    return unless @status.local? && @status.distributable?

    @account.featured_tags.where(tag_id: new_tag_ids).each do |featured_tag|
      featured_tag.increment(now)
    end
  end

  def reset_status_caches
    Rails.cache.delete_matched("statuses/#{@status.id}-*")
    Rails.cache.delete("statuses/#{@status.id}")
    Rails.cache.delete(@status)
    redis.zremrangebyscore("spam_check:#{@account.id}", @status.id, @status.id)
  end

  def distribute
    LinkCrawlWorker.perform_in(rand(1..30).seconds, @status.id) unless @status.spoiler_text?
    DistributionWorker.perform_async(@status.id)
    ActivityPub::DistributionWorker.perform_async(@status.id) if @status.local? && !@status.local_only?

    mentions = @status.active_mentions.includes(:account).where(id: @new_mention_ids, accounts: { domain: nil })
    mentions.each { |mention| LocalNotificationWorker.perform_async(mention.account.id, mention.id, mention.class.name) }
  end
end
