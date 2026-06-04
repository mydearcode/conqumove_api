require "test_helper"

class Api::V1::AuthFlowTest < ActionDispatch::IntegrationTest
  test "registers and returns bearer token" do
    assert_difference("User.count", 1) do
      assert_difference("ApiToken.count", 2) do
        post "/api/v1/auth/register", params: {
          email: "auth@example.com",
          password: "password123",
          password_confirmation: "password123"
        }, as: :json
      end
    end

    assert_response :created
    body = response.parsed_body
    assert body["access_token"].present?
    assert body["refresh_token"].present?
    assert_equal "auth@example.com", body.dig("user", "email")
  end

  test "returns invalid credentials as unauthorized with standard error payload" do
    user = User.create!(
      email: "bad-login@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post "/api/v1/auth/login", params: {
      email: user.email,
      password: "wrong-password"
    }, as: :json

    assert_response :unauthorized
    assert_equal "invalid_credentials", response.parsed_body.dig("error", "code")
  end

  test "rotates refresh token" do
    user = User.create!(
      email: "refresh@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    issued = Auth::TokenIssuer.new.call(user: user)

    assert_difference("ApiToken.count", 2) do
      post "/api/v1/auth/refresh", params: {
        refresh_token: issued.refresh_token
      }, as: :json
    end

    assert_response :success
    body = response.parsed_body
    assert body["access_token"].present?
    assert body["refresh_token"].present?
    assert_predicate issued.refresh_token_record.reload.revoked_at, :present?
  end

  test "returns invalid refresh token as unauthorized with standard error payload" do
    post "/api/v1/auth/refresh", params: {
      refresh_token: "invalid-token"
    }, as: :json

    assert_response :unauthorized
    assert_equal "invalid_refresh_token", response.parsed_body.dig("error", "code")
  end

  test "requires authentication for protected endpoints" do
    post "/api/v1/session/start", params: {
      device_id: "ios-device",
      activity_type: "walking",
      platform: "ios"
    }, as: :json

    assert_response :unauthorized
    assert_equal "unauthorized", response.parsed_body.dig("error", "code")
  end
end
