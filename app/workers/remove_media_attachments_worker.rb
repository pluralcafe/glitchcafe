# frozen_string_literal: true

class RemoveMediaAttachmentsWorker
  include Sidekiq::Worker

  def perform(attachment_ids)
    RemoveMediaAttachmentsService.new.call(attachment_ids)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
