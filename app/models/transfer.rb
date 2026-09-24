# frozen_string_literal: true

class Transfer < ApplicationRecord
  belongs_to :from_account, class_name: "Account"
  belongs_to :to_account, class_name: "Account"
  belongs_to :fx_quote, optional: true

  enum :status, { pending: "pending", completed: "completed", failed: "failed" }, default: :pending

  validates :amount_cents, numericality: { greater_than: 0 }
  validates :idempotency_key, uniqueness: true, allow_nil: true

  def amount_dollars
    return 0.0 unless amount_cents

    amount_cents / 100.0
  end

  def formatted_amount
    format("$%.2f", amount_dollars)
  end
end
