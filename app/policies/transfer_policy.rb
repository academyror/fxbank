# frozen_string_literal: true

class TransferPolicy < ApplicationPolicy
  def show?
    return false unless user.present?

    user.admin? || user.compliance_officer? ||
      record.from_account.user_id == user.id ||
      record.to_account.user_id == user.id
  end

  def create?
    return false unless user.present?

    record.from_account.user_id == user.id && record.from_account.active?
  end
end
