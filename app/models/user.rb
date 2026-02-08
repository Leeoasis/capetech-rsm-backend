class User < ApplicationRecord
  has_secure_password

  enum :role, { admin: 0, technician: 1, cashier: 2 }

  # Associations
  has_many :repair_tickets, foreign_key: :assigned_technician_id, dependent: :nullify
  has_many :activity_logs, dependent: :destroy
  has_many :refresh_tokens, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }, on: :create
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true

  # Methods
  def full_name
    "#{first_name} #{last_name}"
  end
end
