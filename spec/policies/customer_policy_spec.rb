require 'rails_helper'

RSpec.describe CustomerPolicy, type: :policy do
  subject { described_class }

  let(:admin) { create(:user, role: :admin) }
  let(:technician) { create(:user, role: :technician) }
  let(:cashier) { create(:user, role: :cashier) }
  let(:customer) { create(:customer) }

  permissions :index?, :show?, :create?, :update? do
    it "grants access to admin" do
      expect(subject).to permit(admin, customer)
    end

    it "grants access to technician" do
      expect(subject).to permit(technician, customer)
    end

    it "grants access to cashier" do
      expect(subject).to permit(cashier, customer)
    end
  end

  permissions :destroy? do
    it "grants access to admin" do
      expect(subject).to permit(admin, customer)
    end

    it "denies access to technician" do
      expect(subject).not_to permit(technician, customer)
    end

    it "denies access to cashier" do
      expect(subject).not_to permit(cashier, customer)
    end
  end
end
