class Customer < ApplicationRecord
  # Associations
  has_many :devices, dependent: :destroy
  has_many :repair_tickets, dependent: :destroy

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :phone, format: { with: /\A[\d\s\+\-\(\)]+\z/, allow_blank: true }
  validate :email_or_phone_present

  # Scopes
  scope :active, -> { where(active: true) }
  scope :with_deleted, -> { unscope(where: :deleted_at) }
  scope :by_name_or_phone, ->(search) {
    where("first_name ILIKE ? OR last_name ILIKE ? OR phone ILIKE ?", 
          "%#{search}%", "%#{search}%", "%#{search}%")
  }

  # Soft delete support
  default_scope { where(deleted_at: nil) }

  def soft_delete
    update(deleted_at: Time.current)
  end

  private

  def email_or_phone_present
    if email.blank? && phone.blank?
      errors.add(:base, "Either email or phone must be present")
    end
  end
end
