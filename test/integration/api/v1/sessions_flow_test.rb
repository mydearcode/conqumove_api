require "test_helper"

class Api::V1::SessionsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "runner@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = Auth::TokenIssuer.new.call(user: @user).access_token
  end

  test "starts a movement session" do
    assert_difference("MovementSession.count", 1) do
      post "/api/v1/session/start", params: {
        device_id: "ios-sim-1",
        activity_type: "walking",
        platform: "ios"
      }, headers: auth_headers(@token), as: :json
    end

    assert_response :created
    body = response.parsed_body
    assert_equal "walking", body["activity_type"]
    assert_equal "active", body["status"]
  end

  private

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
