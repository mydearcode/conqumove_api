module PublicApi
  class RateLimiter
    LimitExceeded = Class.new(StandardError) do
      attr_reader :retry_after, :scope, :limit, :period

      def initialize(message: "Rate limit exceeded", retry_after:, scope:, limit:, period:)
        super(message)
        @retry_after = retry_after
        @scope = scope
        @limit = limit
        @period = period
      end
    end

    def call(scope:, actor:, limit:, period:)
      cache_key = "public_api_rate_limit:#{scope}:#{Digest::SHA256.hexdigest(actor.to_s)}"
      now = Time.current
      window = Rails.cache.read(cache_key)

      if window.blank? || window[:reset_at].to_time <= now
        window = { count: 0, reset_at: now + period }
      end

      window[:count] += 1
      Rails.cache.write(cache_key, window, expires_in: period)

      return window[:count] if window[:count] <= limit

      raise LimitExceeded.new(
        retry_after: [(window[:reset_at].to_time - now).ceil, 1].max,
        scope: scope,
        limit: limit,
        period: period
      )
    end
  end
end
