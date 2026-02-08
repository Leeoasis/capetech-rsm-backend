class RepairTicket < ApplicationRecord
  belongs_to :device
  belongs_to :customer
  belongs_to :assigned_technician, class_name: 'User', optional: true

  # Associations
  has_many :repair_statuses, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :activity_logs, dependent: :destroy

  # Enums
  enum :status, { pending: 0, in_progress: 1, waiting_for_parts: 2, completed: 3, collected: 4, cancelled: 5 }
  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }

  # Validations
  validates :ticket_number, uniqueness: true
  validates :fault_description, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :customer_id, presence: true
  validates :device_id, presence: true

  # Scopes
  scope :by_status, ->(status) { where(status: status) }
  scope :by_technician, ->(technician_id) { where(assigned_technician_id: technician_id) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :pending, -> { where(status: :pending) }
  scope :in_progress, -> { where(status: :in_progress) }
  scope :completed, -> { where(status: :completed) }
  scope :uncollected, -> { where(status: :completed).where(collected_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_create :generate_ticket_number

  private

  def generate_ticket_number
    self.ticket_number ||= "RT#{Time.current.strftime('%Y%m%d')}#{SecureRandom.hex(4).upcase}"
  end
end
