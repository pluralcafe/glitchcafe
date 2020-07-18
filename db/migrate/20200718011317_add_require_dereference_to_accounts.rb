class AddRequireDereferenceToAccounts < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :accounts, :require_dereference, :boolean, null: false, default: false
    end
  end
end
