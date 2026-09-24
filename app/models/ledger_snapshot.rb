# frozen_string_literal: true

class LedgerSnapshot < ApplicationRecord
  belongs_to :ledger_account

  validates :balance_subunits, :currency, :snapshot_at, presence: true

  def money
    ValueObjects::Money.new(balance_subunits, currency)
  end
end
