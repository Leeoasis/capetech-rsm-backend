class RepairStatus < ApplicationRecord
  belongs_to :repair_ticket
  belongs_to :changed_by, class_name: 'User', foreign_key: :changed_by_user_id, optional: true

  # Enums - same as RepairTicket
  enum :status, { pending: 0, in_progress: 1, waiting_for_parts: 2, completed: 3, collected: 4, cancelled: 5 }

  # Validations
  validates :status, presence: true
  validates :repair_ticket_id, presence: true
end
