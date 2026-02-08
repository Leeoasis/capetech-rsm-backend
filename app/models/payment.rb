class Payment < ApplicationRecord
  belongs_to :repair_ticket
  belongs_to :received_by, class_name: 'User', foreign_key: :received_by_user_id, optional: true

  # Enums
  enum :payment_method, { cash: 0, card: 1, bank_transfer: 2, other: 3 }

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, presence: true
  validates :repair_ticket_id, presence: true
  validates :payment_date, presence: true

  # Scopes
  scope :by_date_range, ->(start_date, end_date) { where(payment_date: start_date..end_date) }
  scope :by_method, ->(method) { where(payment_method: method) }
  scope :total_collected, -> { sum(:amount) }
end
