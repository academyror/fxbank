# frozen_string_literal: true

class FxQuote < ApplicationRecord
  belongs_to :user
  has_many :transfers, dependent: :nullify

  enum :status, { pending: "pending", executed: "executed", expired: "expired" }, default: :pending

  validates :from_currency, :to_currency, presence: true
  validates :source_amount_subunits, :target_amount_subunits, numericality: { greater_than: 0 }
  validates :market_rate, :effective_rate, numericality: { greater_than: 0 }
  validates :expires_at, presence: true

  scope :active, -> { where(status: "pending").where("expires_at > ?", Time.current) }
  scope :expired_unsettled, -> { where(status: "pending").where("expires_at <= ?", Time.current) }

  def active?
    status == "pending" && expires_at.present? && expires_at > Time.current
  end

  def expired?
    !active?
  end

  def seconds_remaining
    return 0 if expired?

    [ (expires_at - Time.current).to_i, 0 ].max
  end

  def source_money
    ValueObjects::Money.new(source_amount_subunits, from_currency)
  end

  def target_money
    ValueObjects::Money.new(target_amount_subunits, to_currency)
  end
end
