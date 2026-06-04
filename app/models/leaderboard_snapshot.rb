class LeaderboardSnapshot < ApplicationRecord
  validates :scope, presence: true
  validates :data, presence: true

  scope :recent_first, -> { order(created_at: :desc) }
end
