# frozen_string_literal: true

class CreateTransfers < ActiveRecord::Migration[7.2]
  def change
    create_table :transfers do |t|
      t.references :from_account, null: false, foreign_key: { to_table: :accounts }
      t.references :to_account, null: false, foreign_key: { to_table: :accounts }
      t.bigint :amount_cents, null: false
      t.string :status, null: false, default: "pending"
      t.string :idempotency_key
      t.string :description

      t.timestamps
    end

    add_index :transfers, :idempotency_key, unique: true
    add_check_constraint :transfers, "amount_cents > 0", name: "check_transfer_amount_positive"
  end
end
