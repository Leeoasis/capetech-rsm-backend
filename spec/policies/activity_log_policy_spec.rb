require 'rails_helper'

RSpec.describe ActivityLogPolicy, type: :policy do
  subject { described_class }

  let(:admin) { create(:user, role: :admin) }
  let(:technician) { create(:user, role: :technician) }
  let(:cashier) { create(:user, role: :cashier) }
  let(:customer) { create(:customer) }
  let(:device) { create(:device, customer: customer) }
  let(:ticket) { create(:repair_ticket, device: device) }
  let(:activity_log) { create(:activity_log, repair_ticket: ticket, user: technician) }

  permissions :index?, :show?, :create? do
    it "grants access to admin" do
      expect(subject).to permit(admin, activity_log)
    end

    it "grants access to technician" do
      expect(subject).to permit(technician, activity_log)
    end

    it "grants access to cashier" do
      expect(subject).to permit(cashier, activity_log)
    end
  end

  permissions :update? do
    it "denies access to admin" do
      expect(subject).not_to permit(admin, activity_log)
    end

    it "denies access to technician" do
      expect(subject).not_to permit(technician, activity_log)
    end

    it "denies access to cashier" do
      expect(subject).not_to permit(cashier, activity_log)
    end
  end

  permissions :destroy? do
    it "grants access to admin" do
      expect(subject).to permit(admin, activity_log)
    end

    it "denies access to technician" do
      expect(subject).not_to permit(technician, activity_log)
    end

    it "denies access to cashier" do
      expect(subject).not_to permit(cashier, activity_log)
    end
  end
end
