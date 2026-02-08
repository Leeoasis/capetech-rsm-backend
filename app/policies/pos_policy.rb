# frozen_string_literal: true

class PosPolicy < ApplicationPolicy
  def create?
    user&.admin? || user&.cashier?
  end

  def show?
    user&.admin? || user&.cashier?
  end
end
