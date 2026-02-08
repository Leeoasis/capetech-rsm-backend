# frozen_string_literal: true

class RepairTicketPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    return true if user&.admin?
    return true if user&.technician? && record.assigned_technician_id == user.id
    return true if user&.cashier?
    false
  end

  def destroy?
    user&.admin?
  end

  def update_status?
    return true if user&.admin?
    return true if user&.technician? && record.assigned_technician_id == user.id
    return true if user&.cashier?
    false
  end

  def timeline?
    user.present?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.technician?
        scope.where(assigned_technician_id: user.id).or(scope.where(assigned_technician_id: nil))
      elsif user.cashier?
        scope.all
      else
        scope.none
      end
    end
  end
end
