# frozen_string_literal: true

class EnhanceAccountsForMultiCurrency < ActiveRecord::Migration[7.2]
  def change
    add_column :accounts, :account_type, :string, default: "checking", null: false

    add_index :accounts, %i[user_id currency account_type],
              unique: true,
              name: "index_accounts_on_user_currency_and_type"

    add_check_constraint :accounts,
                         "currency IN ('USD', 'EUR', 'GBP', 'JPY', 'CHF')",
                         name: "check_accounts_supported_currency"
  end
end
