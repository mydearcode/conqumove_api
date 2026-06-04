require "digest"

class ApiToken < ApplicationRecord
  ACCESS_TOKEN_TTL = 30.minutes
  REFRESH_TOKEN_TTL = 30.days

  belongs_to :user
  belongs_to :replaced_by, class_name: "ApiToken", optional: true

  enum :token_kind, { access: "access", refresh: "refresh" }, validate: true
  validates :token_digest, presence: true, uniqueness: true

  scope :active, -> { where(revoked_at: nil).where("expires_at > ?", Time.current) }

  def self.issue_for(user:, token_kind:, expires_at:)
    raw_token = SecureRandom.hex(32)
    api_token = user.api_tokens.create!(
      token_digest: digest(raw_token),
      token_kind: token_kind,
      expires_at: expires_at,
      last_used_at: Time.current
    )

    [api_token, raw_token]
  end

  def self.authenticate(raw_token, token_kind: :access)
    return if raw_token.blank?

    token = find_by(token_digest: digest(raw_token))
    return if token.nil? || token.revoked_at.present? || token.expires_at.past?
    return unless token.token_kind == token_kind.to_s

    token
  end

  def self.digest(raw_token)
    Digest::SHA256.hexdigest(raw_token.to_s)
  end

  def revoke!(replacement: nil)
    update!(revoked_at: Time.current, replaced_by: replacement)
  end
end
