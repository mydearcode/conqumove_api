class TerritoryEvent < ApplicationRecord
  belongs_to :territory
  belongs_to :user, optional: true
  belongs_to :movement_session, optional: true

  enum :event_type, { influence_applied: 0, capture: 1, decay_tick: 2 }, validate: true

  validates :payload, presence: true
end
