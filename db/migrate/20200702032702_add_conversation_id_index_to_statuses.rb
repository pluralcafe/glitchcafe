class AddConversationIdIndexToStatuses < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured { add_index :statuses, :conversation_id, where: 'deleted_at IS NULL', algorithm: :concurrently, name: :index_statuses_on_conversation_id }
  end
end
