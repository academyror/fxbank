# frozen_string_literal: true

class LedgerEntry < ApplicationRecord
  belongs_to :ledger_journal
  belongs_to :ledger_account

  enum :entry_type, { debit: "debit", credit: "credit" }

  validates :entry_type, :amount_subunits, :currency, presence: true
  validates :amount_subunits, numericality: { greater_than: 0 }
  validates :currency, inclusion: { in: %w[USD EUR GBP JPY CHF] }

  def money
    ValueObjects::Money.new(amount_subunits, currency)
  end
end
