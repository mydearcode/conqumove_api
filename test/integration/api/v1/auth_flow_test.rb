require "test_helper"

class Api::V1::AuthFlowTest < ActionDispatch::IntegrationTest
  test "registers and returns bearer token" do
    assert_difference(["User.count", "ApiToken.count"], 1) do
      post "/api/v1/auth/register", params: {
        email: "auth@example.com",
        password: "password123",
        password_confirmation: "password123"
      }, as: :json
    end

    assert_response :created
    body = response.parsed_body
    assert body["access_token"].present?
    assert_equal "auth@example.com", body.dig("user", "email")
  end

  test "requires authentication for protected endpoints" do
    post "/api/v1/session/start", params: {
      device_id: "ios-device",
      activity_type: "walking",
      platform: "ios"
    }, as: :json

    assert_response :unauthorized
  end
end
