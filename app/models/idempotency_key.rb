class IdempotencyKey < ApplicationRecord
  validates :scope, :key, :request_fingerprint, presence: true
  validates :key, uniqueness: { scope: :scope }
end
