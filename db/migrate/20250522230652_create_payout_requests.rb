class CreatePayoutRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :payout_requests do |t|
      t.string :payout_request_id, null: false
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
