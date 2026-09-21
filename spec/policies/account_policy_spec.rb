# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountPolicy do
  subject { described_class.new(user, account) }

  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let(:account) { create(:account, user: owner, status: 'active') }

  context 'when user is the account owner' do
    let(:user) { owner }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:transfer) }
  end

  context 'when user is an administrator' do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_action(:show) }
  end

  context 'when user is another unrelated customer' do
    let(:user) { other_user }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:transfer) }
  end
end
