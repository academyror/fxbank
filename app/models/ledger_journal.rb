# frozen_string_literal: true

class LedgerJournal < ApplicationRecord
  has_many :ledger_entries, dependent: :restrict_with_error

  enum :status, { posted: "posted", voided: "voided" }, default: :posted

  validates :description, :posted_at, presence: true

  def balanced?
    sums_by_currency = Hash.new { |h, k| h[k] = { debit: 0, credit: 0 } }

    ledger_entries.each do |e|
      sums_by_currency[e.currency][e.entry_type.to_sym] += e.amount_subunits
    end

    return false if sums_by_currency.empty?

    sums_by_currency.all? { |_, totals| totals[:debit] == totals[:credit] }
  end
end
