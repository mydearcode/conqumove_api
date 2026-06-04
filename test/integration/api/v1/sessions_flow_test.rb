require "test_helper"

class Api::V1::SessionsFlowTest < ActionDispatch::IntegrationTest
  test "starts a movement session" do
    user = User.create!(
      email: "runner@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    assert_difference("MovementSession.count", 1) do
      post "/api/v1/session/start", params: {
        user_id: user.id,
        device_id: "ios-sim-1",
        activity_type: "walking",
        platform: "ios"
      }, as: :json
    end

    assert_response :created
    body = response.parsed_body
    assert_equal "walking", body["activity_type"]
    assert_equal "active", body["status"]
  end
end
