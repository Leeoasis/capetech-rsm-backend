require 'rails_helper'

RSpec.describe PaymentPolicy, type: :policy do
  subject { described_class }

  let(:admin) { create(:user, role: :admin) }
  let(:technician) { create(:user, role: :technician) }
  let(:cashier) { create(:user, role: :cashier) }
  let(:customer) { create(:customer) }
  let(:device) { create(:device, customer: customer) }
  let(:ticket) { create(:repair_ticket, device: device) }
  let(:payment) { create(:payment, repair_ticket: ticket) }

  permissions :index?, :show? do
    it "grants access to admin" do
      expect(subject).to permit(admin, payment)
    end

    it "grants access to technician" do
      expect(subject).to permit(technician, payment)
    end

    it "grants access to cashier" do
      expect(subject).to permit(cashier, payment)
    end
  end

  permissions :create? do
    it "grants access to admin" do
      expect(subject).to permit(admin, payment)
    end

    it "denies access to technician" do
      expect(subject).not_to permit(technician, payment)
    end

    it "grants access to cashier" do
      expect(subject).to permit(cashier, payment)
    end
  end

  permissions :update?, :destroy? do
    it "grants access to admin" do
      expect(subject).to permit(admin, payment)
    end

    it "denies access to technician" do
      expect(subject).not_to permit(technician, payment)
    end

    it "denies access to cashier" do
      expect(subject).not_to permit(cashier, payment)
    end
  end
end
