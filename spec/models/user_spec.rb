# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:accounts).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_inclusion_of(:kyc_status).in_array(%w[pending verified rejected]) }
  end

  describe 'methods' do
    let(:user) { build(:user, first_name: 'Alice', last_name: 'Smith', kyc_status: 'verified') }

    it 'returns full_name cleanly' do
      expect(user.full_name).to eq('Alice Smith')
    end

    it 'checks kyc_verified?' do
      expect(user.kyc_verified?).to be true
      user.kyc_status = 'pending'
      expect(user.kyc_verified?).to be false
    end
  end
end
