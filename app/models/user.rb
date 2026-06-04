class User < ApplicationRecord
  has_secure_password

  enum :role, { player: "player", admin: "admin" }, validate: true

  has_many :api_tokens, dependent: :destroy
  has_many :devices, dependent: :destroy
  has_many :movement_sessions, dependent: :destroy

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :city, with: ->(value) { value.to_s.strip.presence }
  normalizes :region, with: ->(value) { value.to_s.strip.presence }

  validates :email, presence: true, uniqueness: true
end
