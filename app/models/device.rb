class Device < ApplicationRecord
  belongs_to :user
  has_many :movement_sessions, dependent: :nullify

  enum :platform, { ios: "ios", android: "android" }, validate: true

  validates :device_identifier, presence: true, uniqueness: { scope: :user_id }
end
