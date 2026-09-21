# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransferMailer, type: :mailer do
  let(:sender) { create(:user, first_name: 'Alice', email: 'alice@fxbank.io') }
  let(:recipient) { create(:user, first_name: 'Bob', email: 'bob@fxbank.io') }
  let(:from_account) { create(:account, user: sender, account_number: 'FX-100001') }
  let(:to_account) { create(:account, user: recipient, account_number: 'FX-200001') }
  let(:transfer) { create(:transfer, from_account: from_account, to_account: to_account, amount_cents: 15_000) }

  describe '#transfer_sent' do
    let(:mail) { described_class.transfer_sent(transfer) }

    it 'renders headers and delivery to sender' do
      expect(mail.to).to include('alice@fxbank.io')
      expect(mail.subject).to include('Transfer of $150.00 Sent')
    end

    it 'renders body with transaction details' do
      body = mail.body.parts.any? ? mail.parts.map { |p| p.body.decoded }.join("\n") : mail.body.decoded
      expect(body).to include('$150.00')
      expect(body).to include('FX-100001')
      expect(body).to include('FX-200001')
    end
  end

  describe '#transfer_received' do
    let(:mail) { described_class.transfer_received(transfer) }

    it 'renders headers and delivery to recipient' do
      expect(mail.to).to include('bob@fxbank.io')
      expect(mail.subject).to include('Credit Notice')
    end

    it 'renders body with credited amount' do
      body = mail.body.parts.any? ? mail.parts.map { |p| p.body.decoded }.join("\n") : mail.body.decoded
      expect(body).to include('$150.00')
      expect(body).to include('FX-200001')
    end
  end
end
