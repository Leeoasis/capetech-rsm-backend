class RefreshToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true
  validates :user_id, presence: true
  validates :expires_at, presence: true

  scope :active, -> { where('expires_at > ?', Time.current) }

  before_create :generate_token

  def expired?
    expires_at < Time.current
  end

  private

  def generate_token
    self.token = SecureRandom.hex(32)
  end
end
