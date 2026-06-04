class LeaderboardSnapshot < ApplicationRecord
  validates :scope, presence: true
  validates :data, presence: true

  scope :recent_first, -> { order(created_at: :desc) }
  scope :for_scope, ->(scope, scope_value = nil) { where(scope: scope, scope_value: scope_value.presence) }
end
