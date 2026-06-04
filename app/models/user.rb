class User < ApplicationRecord
  has_secure_password

  has_many :api_tokens, dependent: :destroy
  has_many :devices, dependent: :destroy
  has_many :movement_sessions, dependent: :destroy

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: true
end
