# frozen_string_literal: true

class Api::V1::Admin::DomainBlocksController < Api::BaseController
  include Authorization

  LIMIT = 100

  before_action -> { doorkeeper_authorize! :'admin:read', :'admin:read:domain_blocks' }, only: :show
  before_action :require_staff!
  after_action :insert_pagination_headers, only: :show

  def show
    @blocks = load_domain_blocks
    render json: @blocks
  end

  private

  def load_domain_blocks
    DomainBlock.paginate_by_max_id(
      limit_param(LIMIT),
      params[:max_id],
      params[:since_id]
    )
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    api_v1_admin_domain_blocks_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    api_v1_admin_domain_blocks_url pagination_params(since_id: pagination_since_id) unless @blocks.empty?
  end

  def pagination_max_id
    @blocks.last.id
  end

  def pagination_since_id
    @blocks.first.id
  end

  def records_continue?
    @blocks.size == limit_param(LIMIT)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end
end
