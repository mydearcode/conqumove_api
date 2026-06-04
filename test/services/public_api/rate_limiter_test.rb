require "test_helper"

class PublicApi::RateLimiterTest < ActiveSupport::TestCase
  test "allows requests up to configured limit" do
    limiter = PublicApi::RateLimiter.new

    assert_equal 1, limiter.call(scope: "auth#login", actor: "127.0.0.1", limit: 2, period: 1.minute)
    assert_equal 2, limiter.call(scope: "auth#login", actor: "127.0.0.1", limit: 2, period: 1.minute)
  end

  test "raises once limit is exceeded" do
    limiter = PublicApi::RateLimiter.new
    limiter.call(scope: "movement#create", actor: "user-1", limit: 1, period: 30.seconds)

    error = assert_raises(PublicApi::RateLimiter::LimitExceeded) do
      limiter.call(scope: "movement#create", actor: "user-1", limit: 1, period: 30.seconds)
    end

    assert_equal 30, error.retry_after
    assert_equal "movement#create", error.scope
  end
end
