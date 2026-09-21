# frozen_string_literal: true

class TransferNotificationJob < ApplicationJob
  queue_as :mailers

  def perform(transfer_id)
    transfer = Transfer.find_by(id: transfer_id)
    return unless transfer

    TransferMailer.transfer_sent(transfer).deliver_now
    TransferMailer.transfer_received(transfer).deliver_now
  rescue StandardError => e
    Rails.logger.error("[TransferNotificationJob] Error dispatching transfer notification for ##{transfer_id}: #{e.message}")
    raise e
  end
end
