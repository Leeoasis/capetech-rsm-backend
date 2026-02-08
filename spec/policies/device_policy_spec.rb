require 'rails_helper'

RSpec.describe DevicePolicy, type: :policy do
  subject { described_class }

  let(:admin) { create(:user, role: :admin) }
  let(:technician) { create(:user, role: :technician) }
  let(:cashier) { create(:user, role: :cashier) }
  let(:device) { create(:device) }

  permissions :index?, :show?, :create?, :update? do
    it "grants access to admin" do
      expect(subject).to permit(admin, device)
    end

    it "grants access to technician" do
      expect(subject).to permit(technician, device)
    end

    it "grants access to cashier" do
      expect(subject).to permit(cashier, device)
    end
  end

  permissions :destroy? do
    it "grants access to admin" do
      expect(subject).to permit(admin, device)
    end

    it "denies access to technician" do
      expect(subject).not_to permit(technician, device)
    end

    it "denies access to cashier" do
      expect(subject).not_to permit(cashier, device)
    end
  end
end
