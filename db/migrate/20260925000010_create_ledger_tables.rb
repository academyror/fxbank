# frozen_string_literal: true

class CreateLedgerTables < ActiveRecord::Migration[7.2]
  def change
    # 1. Chart of Accounts
    create_table :ledger_accounts, id: :uuid do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :account_type, null: false # asset, liability, equity, revenue, expense
      t.string :currency, null: false, limit: 3
      t.bigint :cached_balance_subunits, default: 0, null: false
      t.integer :lock_version, default: 0, null: false
      t.references :account, foreign_key: true, null: true

      t.timestamps
    end

    add_index :ledger_accounts, :code, unique: true
    add_index :ledger_accounts, %i[currency account_type]

    # 2. Transaction Containers (Journals)
    create_table :ledger_journals, id: :uuid do |t|
      t.string :description, null: false
      t.string :reference_type
      t.string :reference_id
      t.string :status, default: "posted", null: false
      t.datetime :posted_at, null: false

      t.timestamps
    end

    add_index :ledger_journals, %i[reference_type reference_id]
    add_index :ledger_journals, :posted_at

    # 3. Individual Postings (Entries)
    create_table :ledger_entries, id: :uuid do |t|
      t.references :ledger_journal, null: false, foreign_key: true, type: :uuid
      t.references :ledger_account, null: false, foreign_key: true, type: :uuid
      t.string :entry_type, null: false
      t.bigint :amount_subunits, null: false
      t.string :currency, null: false, limit: 3

      t.timestamps
    end

    add_check_constraint :ledger_entries, "entry_type IN ('debit', 'credit')", name: "check_ledger_entry_type"
    add_check_constraint :ledger_entries, "amount_subunits > 0", name: "check_ledger_entry_amount_positive"
  end
end
