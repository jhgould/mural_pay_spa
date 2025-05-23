class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.string :account_source_id, null: false

      t.timestamps
    end
  end
end
