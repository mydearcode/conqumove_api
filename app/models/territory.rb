class Territory < ApplicationRecord
  belongs_to :owner, class_name: "User", optional: true
  has_many :territory_events, dependent: :destroy

  validates :hex_id, presence: true, uniqueness: { scope: :resolution }

  def stability_margin
    stability_score - pressure_score
  end
end
