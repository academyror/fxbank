# frozen_string_literal: true

class AccountPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? && (user.admin? || user.compliance_officer? || record.user_id == user.id)
  end

  def transfer?
    user.present? && record.user_id == user.id && record.active?
  end

  class Scope < Scope
    def resolve
      if user.admin? || user.compliance_officer?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end
end
