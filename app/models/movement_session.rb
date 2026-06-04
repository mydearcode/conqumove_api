class MovementSession < ApplicationRecord
  belongs_to :user
  belongs_to :device
  has_many :gps_points, dependent: :destroy
  has_many :territory_events, dependent: :nullify

  enum :activity_type, { walking: 0, running: 1 }, prefix: :activity, validate: true
  enum :status, { active: 0, paused: 1, ended: 2, invalid: 3 }, prefix: true, validate: true

  validates :started_at, presence: true

  def trust_factor
    trust_score.to_f / 100.0
  end
end
