class AdminActionLog < ApplicationRecord
  belongs_to :user

  enum :status, {
    accepted: "accepted",
    forbidden: "forbidden",
    rate_limited: "rate_limited",
    error: "error"
  }, validate: true

  validates :action_name, :status, :occurred_at, presence: true
end
