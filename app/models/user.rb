# frozen_string_literal: true

class User < ApplicationRecord
  has_many :accounts, dependent: :restrict_with_error

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, :last_name, presence: true
  validates :kyc_status, inclusion: { in: %w[pending verified rejected] }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def kyc_verified?
    kyc_status == "verified"
  end
end
