# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transfer, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:from_account).class_name('Account') }
    it { is_expected.to belong_to(:to_account).class_name('Account') }
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:amount_cents).is_greater_than(0) }
  end

  describe '#formatted_amount' do
    let(:transfer) { build(:transfer, amount_cents: 12_550) }

    it 'formats amount to dollar string' do
      expect(transfer.formatted_amount).to eq('$125.50')
    end
  end
end
