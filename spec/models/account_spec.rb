# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:sent_transfers).with_foreign_key(:from_account_id).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:received_transfers).with_foreign_key(:to_account_id).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    subject { build(:account) }

    it { is_expected.to validate_numericality_of(:balance_cents).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_inclusion_of(:currency).in_array(%w[USD EUR GBP]) }
  end

  describe 'account number generation' do
    let(:user) { create(:user) }

    it 'auto-generates a unique FX- prefixed account number before creation' do
      account = create(:account, user: user, account_number: nil)
      expect(account.account_number).to match(/\AFX-\d{6}\z/)
    end
  end

  describe '#formatted_balance' do
    let(:account) { build(:account, balance_cents: 250_000, currency: 'USD') }

    it 'formats balance in dollars with currency symbol' do
      expect(account.formatted_balance).to eq('$2500.00 USD')
    end
  end
end
