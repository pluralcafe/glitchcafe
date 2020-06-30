# frozen_string_literal: true

class ProcessMentionsService < BaseService
  include Payloadable

  # Scan status for mentions and fetch remote mentioned users, create
  # local mention pointers, send Salmon notifications to mentioned
  # remote users
  # @param [Status] status
  # @option [Enumerable] :mentions Mentions to include
  # @option [Boolean] :reveal_implicit_mentions Append implicit mentions to text
  def call(status, mentions: [], reveal_implicit_mentions: true)
    return unless status.local?

    @status = status
    @status.text, mentions = ResolveMentionsService.new.call(@status, mentions: mentions, reveal_implicit_mentions: reveal_implicit_mentions)
    @status.save!

    check_for_spam(status)

    mentions.each { |mention| create_notification(mention) }
  end

  private

  def create_notification(mention)
    mentioned_account = mention.account

    if mentioned_account.local?
      LocalNotificationWorker.perform_async(mentioned_account.id, mention.id, mention.class.name)
    elsif mentioned_account.activitypub? && !@status.local_only?
      ActivityPub::DeliveryWorker.perform_async(activitypub_json, mention.status.account_id, mentioned_account.inbox_url)
    end
  end

  def activitypub_json
    return @activitypub_json if defined?(@activitypub_json)
    @activitypub_json = Oj.dump(serialize_payload(ActivityPub::ActivityPresenter.from_status(@status), ActivityPub::ActivitySerializer, signer: @status.account))
  end

  def check_for_spam(status)
    SpamCheck.perform(status)
  end
end
