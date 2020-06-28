# frozen_string_literal: true

class Scheduler::AmbassadorScheduler
  include Sidekiq::Worker

  def perform
    @ambassador = find_ambassador_acct
    return if @ambassador.nil?

    status = next_boost
    return if status.nil?

    ReblogService.new.call(@ambassador, status)
  end

  private

  def find_ambassador_acct
    ambassador = ENV['AMBASSADOR_USER'].to_i
    return Account.find_by(id: ambassador) unless ambassador.zero?

    ambassador = ENV['AMBASSADOR_USER']
    return if ambassador.blank?

    Account.find_local(ambassador)
  end

  def next_boost
    ambassador_boost_candidates.first
  end

  def ambassador_boost_candidates
    ambassador_boostable.joins(:status_stat).where('favourites_count + reblogs_count > 4')
  end

  def ambassador_boostable
    ambassador_unboosted.excluding_silenced_accounts.not_excluded_by_account(@ambassador)
  end

  def ambassador_unboosted
    locally_boostable.where.not(id: ambassador_boosts)
  end

  def ambassador_boosts
    @ambassador.statuses.where('statuses.reblog_of_id IS NOT NULL').reorder(nil).select(:reblog_of_id)
  end

  def locally_boostable
    Status.local.public_visibility.without_replies.without_reblogs
  end
end
