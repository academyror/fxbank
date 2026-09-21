# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransferNotificationJob, type: :job do
  let(:transfer) { create(:transfer) }

  describe '#perform' do
    it 'delivers notification emails to both sender and recipient' do
      expect {
        described_class.perform_now(transfer.id)
      }.to change { ActionMailer::Base.deliveries.count }.by(2)
    end
  end
end
