require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  subject { described_class }

  let(:admin) { create(:user, role: :admin) }
  let(:technician) { create(:user, role: :technician) }
  let(:cashier) { create(:user, role: :cashier) }
  let(:other_user) { create(:user, role: :cashier) }

  permissions :index? do
    it "grants access to admin" do
      expect(subject).to permit(admin, User)
    end

    it "denies access to technician" do
      expect(subject).not_to permit(technician, User)
    end

    it "denies access to cashier" do
      expect(subject).not_to permit(cashier, User)
    end
  end

  permissions :show? do
    it "grants access to admin for any user" do
      expect(subject).to permit(admin, other_user)
    end

    it "grants access to view own record" do
      expect(subject).to permit(technician, technician)
    end

    it "denies access to view other user's record" do
      expect(subject).not_to permit(technician, other_user)
    end
  end

  permissions :create? do
    it "grants access to admin" do
      expect(subject).to permit(admin, User)
    end

    it "denies access to technician" do
      expect(subject).not_to permit(technician, User)
    end

    it "denies access to cashier" do
      expect(subject).not_to permit(cashier, User)
    end
  end

  permissions :update? do
    it "grants access to admin for any user" do
      expect(subject).to permit(admin, other_user)
    end

    it "grants access to update own record" do
      expect(subject).to permit(technician, technician)
    end

    it "denies access to update other user's record" do
      expect(subject).not_to permit(technician, other_user)
    end
  end

  permissions :destroy? do
    it "grants access to admin" do
      expect(subject).to permit(admin, other_user)
    end

    it "denies access to technician" do
      expect(subject).not_to permit(technician, other_user)
    end

    it "denies access to cashier" do
      expect(subject).not_to permit(cashier, other_user)
    end
  end
end
