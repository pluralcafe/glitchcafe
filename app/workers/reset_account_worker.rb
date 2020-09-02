# frozen_string_literal: true

class ResetAccountWorker
  include Sidekiq::Worker

  def perform(account_id)
    account = Account.find(account_id)
    return if account.local?

    account_uri = account.uri
    SuspendAccountService.new.call(account)
    ResolveAccountService.new.call(account_uri)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
