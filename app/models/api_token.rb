require "digest"

class ApiToken < ApplicationRecord
  TOKEN_TTL = 30.days

  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true

  def self.issue_for(user:, expires_at: TOKEN_TTL.from_now)
    raw_token = SecureRandom.hex(32)
    api_token = user.api_tokens.create!(
      token_digest: digest(raw_token),
      expires_at: expires_at,
      last_used_at: Time.current
    )

    [api_token, raw_token]
  end

  def self.authenticate(raw_token)
    return if raw_token.blank?

    token = find_by(token_digest: digest(raw_token))
    return if token.nil? || token.expires_at.past?

    token
  end

  def self.digest(raw_token)
    Digest::SHA256.hexdigest(raw_token.to_s)
  end
end
