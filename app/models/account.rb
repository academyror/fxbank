# frozen_string_literal: true

class Account < ApplicationRecord
  belongs_to :user

  has_many :sent_transfers,
           class_name: "Transfer",
           foreign_key: :from_account_id,
           dependent: :restrict_with_error

  has_many :received_transfers,
           class_name: "Transfer",
           foreign_key: :to_account_id,
           dependent: :restrict_with_error

  enum :status, { active: "active", suspended: "frozen", closed: "closed" }, default: :active

  validates :account_number, presence: true, uniqueness: true
  validates :balance_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true, inclusion: { in: %w[USD EUR GBP JPY CHF] }
  validates :account_type, presence: true, inclusion: { in: %w[checking savings operational] }

  before_validation :generate_account_number, on: :create

  def money
    ValueObjects::Money.new(balance_cents, currency)
  end

  def balance_dollars
    money.decimal_amount
  end

  def formatted_balance
    "#{money.format} #{currency}"
  end

  def transfers
    Transfer.where("from_account_id = :id OR to_account_id = :id", id: id).order(created_at: :desc)
  end

  private

  def generate_account_number
    return if account_number.present?

    loop do
      self.account_number = "FX-#{SecureRandom.random_number(100_000..999_999)}"
      break unless Account.exists?(account_number: account_number)
    end
  end
end
