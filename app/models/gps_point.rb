class GpsPoint < ApplicationRecord
  belongs_to :movement_session

  scope :for_batch, ->(batch_uuid) { where(batch_uuid: batch_uuid) }
  scope :ordered, -> { order(:recorded_at, :sequence_no) }

  validates :batch_uuid, :recorded_at, :lat, :lng, presence: true
end
