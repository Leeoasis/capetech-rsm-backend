class Device < ApplicationRecord
  belongs_to :customer

  enum :device_type, { phone: 0, tablet: 1, laptop: 2, desktop: 3, other: 4 }

  # Associations
  has_many :repair_tickets, dependent: :destroy

  # Validations
  validates :device_type, presence: true
  validates :brand, presence: true
  validates :model, presence: true
  validates :customer_id, presence: true

  # Scopes
  scope :by_device_type, ->(type) { where(device_type: type) }
  scope :by_customer, ->(customer_id) { where(customer_id: customer_id) }

  # Soft delete support
  default_scope { where(deleted_at: nil) }

  def soft_delete
    update(deleted_at: Time.current)
  end
end
