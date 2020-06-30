# frozen_string_literal: true

class RemoveMediaAttachmentsService < BaseService
  # Remove a list of media attachments by their IDs
  # @param [Enumerable] attachment_ids
  def call(attachment_ids)
    media_attachments = MediaAttachment.where(id: attachment_ids)
    media_attachments.map(&:id).each { |id| Rails.cache.delete_matched("statuses/#{id}-*") }
    media_attachments.destroy_all
  end
end
