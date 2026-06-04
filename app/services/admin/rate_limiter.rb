module Admin
  class RateLimiter
    LimitExceeded = Class.new(StandardError)

    def call(user:, action_name:, limit:, period:)
      recent_count = AdminActionLog.where(
        user: user,
        action_name: action_name,
        status: :accepted,
        occurred_at: period.ago..Time.current
      ).count

      raise LimitExceeded, "Rate limit exceeded" if recent_count >= limit
    end
  end
end
