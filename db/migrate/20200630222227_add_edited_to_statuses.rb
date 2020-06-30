class AddEditedToStatuses < ActiveRecord::Migration[5.2]
  def up
    add_column :statuses, :edited, :int
    change_column_default :statuses, :edited, 0
  end

  def down
    remove_column :statuses, :edited
  end
end
