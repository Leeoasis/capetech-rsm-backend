require 'rails_helper'

RSpec.describe RepairTicketPolicy, type: :policy do
  subject { described_class }

  let(:admin) { create(:user, role: :admin) }
  let(:technician) { create(:user, role: :technician) }
  let(:other_technician) { create(:user, role: :technician) }
  let(:cashier) { create(:user, role: :cashier) }
  let(:customer) { create(:customer) }
  let(:device) { create(:device, customer: customer) }
  let(:assigned_ticket) { create(:repair_ticket, device: device, assigned_technician: technician) }
  let(:unassigned_ticket) { create(:repair_ticket, device: device) }
  let(:other_ticket) { create(:repair_ticket, device: device, assigned_technician: other_technician) }

  permissions :index?, :show?, :create?, :timeline? do
    it "grants access to admin" do
      expect(subject).to permit(admin, assigned_ticket)
    end

    it "grants access to technician" do
      expect(subject).to permit(technician, assigned_ticket)
    end

    it "grants access to cashier" do
      expect(subject).to permit(cashier, assigned_ticket)
    end
  end

  permissions :update? do
    it "grants access to admin for any ticket" do
      expect(subject).to permit(admin, assigned_ticket)
    end

    it "grants access to technician for assigned tickets" do
      expect(subject).to permit(technician, assigned_ticket)
    end

    it "denies access to technician for non-assigned tickets" do
      expect(subject).not_to permit(technician, other_ticket)
    end

    it "grants access to cashier" do
      expect(subject).to permit(cashier, assigned_ticket)
    end
  end

  permissions :update_status? do
    it "grants access to admin" do
      expect(subject).to permit(admin, assigned_ticket)
    end

    it "grants access to assigned technician" do
      expect(subject).to permit(technician, assigned_ticket)
    end

    it "denies access to non-assigned technician" do
      expect(subject).not_to permit(technician, other_ticket)
    end

    it "grants access to cashier" do
      expect(subject).to permit(cashier, assigned_ticket)
    end
  end

  permissions :destroy? do
    it "grants access to admin" do
      expect(subject).to permit(admin, assigned_ticket)
    end

    it "denies access to technician" do
      expect(subject).not_to permit(technician, assigned_ticket)
    end

    it "denies access to cashier" do
      expect(subject).not_to permit(cashier, assigned_ticket)
    end
  end

  describe 'Scope' do
    let!(:assigned_to_tech) { create(:repair_ticket, device: device, assigned_technician: technician) }
    let!(:assigned_to_other) { create(:repair_ticket, device: device, assigned_technician: other_technician) }
    let!(:unassigned) { create(:repair_ticket, device: device, assigned_technician: nil) }

    it "returns all tickets for admin" do
      scope = Pundit.policy_scope(admin, RepairTicket)
      expect(scope).to match_array([assigned_to_tech, assigned_to_other, unassigned])
    end

    it "returns assigned and unassigned tickets for technician" do
      scope = Pundit.policy_scope(technician, RepairTicket)
      expect(scope).to match_array([assigned_to_tech, unassigned])
    end

    it "returns all tickets for cashier" do
      scope = Pundit.policy_scope(cashier, RepairTicket)
      expect(scope).to match_array([assigned_to_tech, assigned_to_other, unassigned])
    end
  end
end
