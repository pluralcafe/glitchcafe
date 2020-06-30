# frozen_string_literal: true

class RevokeStatusWorker
  include Sidekiq::Worker

  def perform(status_id, account_ids)
    RevokeStatusService.new.call(Status.find(status_id), account_ids)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
