# frozen_string_literal: true

class LedgerAccount < ApplicationRecord
  belongs_to :account, optional: true
  has_many :ledger_entries, dependent: :restrict_with_error
  has_many :ledger_snapshots, dependent: :destroy

  enum :account_type, {
    asset: "asset",
    liability: "liability",
    equity: "equity",
    revenue: "revenue",
    expense: "expense"
  }

  validates :name, :code, :account_type, :currency, presence: true
  validates :code, uniqueness: true
  validates :currency, inclusion: { in: %w[USD EUR GBP JPY CHF] }

  def money
    ValueObjects::Money.new(cached_balance_subunits, currency)
  end

  def formatted_balance
    money.format
  end

  # Compute pure audit balance directly from source entry lines
  def computed_balance_subunits
    entries = ledger_entries.pluck(:entry_type, :amount_subunits)
    entries.sum do |type, amount|
      if asset? || expense?
        type == "debit" ? amount : -amount
      else
        type == "credit" ? amount : -amount
      end
    end
  end
end
