# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransferPolicy do
  subject { described_class.new(user, transfer) }

  let(:sender) { create(:user) }
  let(:recipient) { create(:user) }
  let(:other_user) { create(:user) }

  let(:from_account) { create(:account, user: sender, status: 'active') }
  let(:to_account) { create(:account, user: recipient, status: 'active') }
  let(:transfer) { create(:transfer, from_account: from_account, to_account: to_account) }

  context 'when user is the sender' do
    let(:user) { sender }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
  end

  context 'when user is the recipient' do
    let(:user) { recipient }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'when user is an administrator' do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_action(:show) }
  end

  context 'when user is an unrelated customer' do
    let(:user) { other_user }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:create) }
  end
end
