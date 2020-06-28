# frozen_string_literal: true

class NodeInfo::Serializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :version, :software, :protocols, :usage, :open_registrations, :metadata

  def version
    '2.0'
  end

  def software
    { name: 'mastodon', version: Mastodon::Version.to_s }
  end

  def services
    { outbound: [], inbound: [] }
  end

  def protocols
    %w(activitypub)
  end

  def usage
    {
      users: {
        total: instance_presenter.user_count,
        active_month: instance_presenter.active_user_count(4),
        active_halfyear: instance_presenter.active_user_count(24),
      },

      local_posts: instance_presenter.status_count,
    }
  end

  def open_registrations
    Setting.registrations_mode != 'none' && !Rails.configuration.x.single_user_mode
  end

  def metadata
    {
      domain_allows: display_allows? ? DomainAllow.all.map { |a| a.slice(:domain) } : [],
      domain_blocks: display_blocks? ? DomainBlock.all.map { |b| b.slice(:domain, :severity, :reject_media, :reject_reports, :public_comment) } : [],
    }
  end

  private

  def instance_presenter
    @instance_presenter ||= InstancePresenter.new
  end

  # Monsterfork additions

  def display_allows?
    Setting.show_domain_allows == 'all' || (Setting.show_domain_allows == 'users' && user_signed_in?)
  end

  def display_blocks?
    Setting.show_domain_blocks == 'all' || (Setting.show_domain_blocks == 'users' && user_signed_in?)
  end
end
