# frozen_string_literal: true

class CreateFxQuotes < ActiveRecord::Migration[7.2]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :fx_quotes, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true
      t.string :from_currency, null: false, limit: 3
      t.string :to_currency, null: false, limit: 3
      t.bigint :source_amount_subunits, null: false
      t.bigint :target_amount_subunits, null: false
      t.decimal :market_rate, precision: 16, scale: 6, null: false
      t.decimal :spread_percent, precision: 5, scale: 2, default: 0.5, null: false
      t.decimal :effective_rate, precision: 16, scale: 6, null: false
      t.bigint :fee_subunits, default: 0, null: false
      t.datetime :expires_at, null: false
      t.string :status, default: "pending", null: false

      t.timestamps
    end

    add_index :fx_quotes, :expires_at
    add_index :fx_quotes, :status
  end
end
