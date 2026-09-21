# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable

  has_many :accounts, dependent: :restrict_with_error

  enum :role, { customer: "customer", compliance_officer: "compliance_officer", admin: "admin" }, default: :customer

  validates :first_name, :last_name, presence: true
  validates :kyc_status, inclusion: { in: %w[pending verified rejected] }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def kyc_verified?
    kyc_status == "verified"
  end

  def admin?
    role == "admin"
  end

  def compliance_officer?
    role == "compliance_officer"
  end
end
