# frozen_string_literal: true

class ResolveMentionsService < BaseService
  # Scan text for mentions and create local mention pointers
  # @param [Status] status Status to attach to mention pointers
  # @option [String] :text Text containing mentions to resolve (default: use status text)
  # @option [Enumerable] :mentions Additional mentions to include
  # @option [Boolean] :reveal_implicit_mentions Append implicit mentions to text
  # @return [Array] Array containing text with mentions resolved (String) and mention pointers (Set)
  def call(status, text: nil, mentions: [], reveal_implicit_mentions: true)
    mentions                  = Mention.includes(:account).where(id: mentions.pluck(:id), accounts: { suspended_at: nil }).to_set
    implicit_mention_acct_ids = mentions.pluck(:account_id).to_set
    text                      = status.text if text.nil?

    text.gsub(Account::MENTION_RE) do |match|
      username, domain = Regexp.last_match(1).split('@')

      domain = begin
        if TagManager.instance.local_domain?(domain)
          nil
        else
          TagManager.instance.normalize_domain(domain)
        end
      end

      mentioned_account = Account.find_remote(username, domain)

      if mention_undeliverable?(mentioned_account)
        begin
          mentioned_account = resolve_account_service.call(Regexp.last_match(1))
        rescue Goldfinger::Error, HTTP::Error, OpenSSL::SSL::SSLError, Mastodon::UnexpectedResponseError
          mentioned_account = nil
        end
      end

      next match if mention_undeliverable?(mentioned_account) || mentioned_account&.suspended?

      mentions << mentioned_account.mentions.where(status: status).first_or_create(status: status)
      implicit_mention_acct_ids.delete(mentioned_account.id)

      "@#{mentioned_account.acct}"
    end

    if reveal_implicit_mentions && implicit_mention_acct_ids.present?
      implicit_mention_accts = Account.where(id: implicit_mention_acct_ids, suspended_at: nil)
      formatted_accts = format_mentions(implicit_mention_accts)
      formatted_accts = Formatter.instance.linkify(formatted_accts, implicit_mention_accts) unless status.local?
      text << formatted_accts
    end

    [text, mentions]
  end

  private

  def mention_undeliverable?(mentioned_account)
    mentioned_account.nil? || (!mentioned_account.local? && mentioned_account.ostatus?)
  end

  def resolve_account_service
    ResolveAccountService.new
  end

  def format_mentions(accounts)
    "\n\n#{accounts_to_mentions(accounts).join(' ')}"
  end

  def accounts_to_mentions(accounts)
    accounts.reorder(:username, :domain).pluck(:username, :domain).map do |username, domain|
      domain.blank? ? "@#{username}" : "@#{username}@#{domain}"
    end
  end
end
