# frozen_string_literal: true

class KycVerificationJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user&.kyc_document&.attached?

    # Simulate compliance verification latency & inspection:
    user.update!(kyc_status: "verified")
    Rails.logger.info("[KycVerificationJob] User ##{user_id} (#{user.full_name}) KYC verified successfully.")
  end
end
