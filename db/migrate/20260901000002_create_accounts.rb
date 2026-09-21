# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :account_number, null: false
      t.bigint :balance_cents, null: false, default: 0
      t.string :currency, null: false, default: "USD"
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :accounts, :account_number, unique: true
    add_check_constraint :accounts, "balance_cents >= 0", name: "check_account_balance_non_negative"
  end
end
