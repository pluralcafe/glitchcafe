class BackfillDefaultStatusesEdited < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    Rails.logger.info('Backfilling "edited" column of table "statuses" to default value 0...')
    Status.unscoped.in_batches do |statuses|
      statuses.update_all(edited: 0)
    end
  end

  def down
    true
  end
end
