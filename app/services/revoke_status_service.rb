# frozen_string_literal: true

class RevokeStatusService < BaseService
  include Redisable
  include Payloadable

  # Unpublish a status from a given set of local accounts' timelines and public, if visibility changed.
  # @param   [Status] status
  # @param   [Enumerable] account_ids
  def call(status, account_ids)
    @payload      = Oj.dump(event: :delete, payload: status.id.to_s)
    @status       = status
    @account      = status.account
    @account_ids  = account_ids
    @mentions     = status.active_mentions.where(account_id: account_ids)
    @reblogs      = status.reblogs.where(account_id: account_ids)

    RedisLock.acquire(lock_options) do |lock|
      if lock.acquired?
        remove_from_followers
        remove_from_lists
        remove_from_affected
        remove_reblogs
        remove_from_hashtags unless @status.distributable?
        remove_from_public
        remove_from_media
        remove_from_direct if status.direct_visibility?
      else
        raise Mastodon::RaceConditionError
      end
    end
  end

  private

  def remove_from_followers
    @account.followers_for_local_distribution.where(id: @account_ids).reorder(nil).find_each do |follower|
      FeedManager.instance.unpush_from_home(follower, @status)
    end
  end

  def remove_from_lists
    @account.lists_for_local_distribution.where(account_id: @account_ids).select(:id, :account_id).reorder(nil).find_each do |list|
      FeedManager.instance.unpush_from_list(list, @status)
    end
  end

  def remove_from_affected
    @mentions.map(&:account).select(&:local?).each do |account|
      redis.publish("timeline:#{account.id}", @payload)
    end
  end

  def remove_reblogs
    @reblogs.each do |reblog|
      RemoveStatusService.new.call(reblog)
    end
  end

  def remove_from_hashtags
    @account.featured_tags.where(tag_id: @status.tags.pluck(:id)).each do |featured_tag|
      featured_tag.decrement(@status.id)
    end

    return unless @status.public_visibility?

    @tags.each do |hashtag|
      redis.publish("timeline:hashtag:#{hashtag.mb_chars.downcase}", @payload)
      redis.publish("timeline:hashtag:#{hashtag.mb_chars.downcase}:local", @payload) if @status.local?
    end
  end

  def remove_from_public
    return if @status.public_visibility?

    redis.publish('timeline:public', @payload)
    if @status.local?
      redis.publish('timeline:public:local', @payload)
    else
      redis.publish('timeline:public:remote', @payload)
    end
  end

  def remove_from_media
    return if @status.public_visibility?

    redis.publish('timeline:public:media', @payload)
    if @status.local?
      redis.publish('timeline:public:local:media', @payload)
    else
      redis.publish('timeline:public:remote:media', @payload)
    end
  end

  def remove_from_direct
    @mentions.each do |mention|
      FeedManager.instance.unpush_from_direct(mention.account, @status) if mention.account.local?
    end
  end

  def lock_options
    { redis: Redis.current, key: "distribute:#{@status.id}" }
  end
end
