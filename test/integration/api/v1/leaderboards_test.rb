require "test_helper"

class Api::V1::LeaderboardsTest < ActionDispatch::IntegrationTest
  setup do
    user = User.create!(
      email: "board@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = Auth::TokenIssuer.new.call(user: user).access_token
    LeaderboardSnapshot.create!(scope: "global", data: { total_territories: 4 })
  end

  test "returns latest snapshot for scope" do
    get "/api/v1/leaderboards/global", headers: auth_headers(@token), as: :json

    assert_response :success
    assert_equal 4, response.parsed_body.dig("data", "total_territories")
  end

  private

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
