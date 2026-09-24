# frozen_string_literal: true

class CreateLedgerSnapshots < ActiveRecord::Migration[7.2]
  def change
    create_table :ledger_snapshots, id: :uuid do |t|
      t.references :ledger_account, null: false, foreign_key: true, type: :uuid
      t.bigint :balance_subunits, null: false
      t.string :currency, null: false, limit: 3
      t.datetime :snapshot_at, null: false

      t.timestamps
    end

    add_index :ledger_snapshots, %i[ledger_account_id snapshot_at]
  end
end
