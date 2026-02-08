class ActivityLog < ApplicationRecord
  belongs_to :user
  belongs_to :repair_ticket, optional: true

  # Validations
  validates :action_type, presence: true
  validates :description, presence: true
  validates :user_id, presence: true
end
