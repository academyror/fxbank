# frozen_string_literal: true

class CreateFxRates < ActiveRecord::Migration[7.2]
  def change
    create_table :fx_rates do |t|
      t.string :from_currency, null: false, limit: 3
      t.string :to_currency, null: false, limit: 3
      t.decimal :rate, precision: 16, scale: 6, null: false
      t.datetime :recorded_at, null: false

      t.timestamps
    end

    add_index :fx_rates, %i[from_currency to_currency recorded_at], name: "index_fx_rates_on_currencies_and_recorded_at"
  end
end
