require "test_helper"

class Api::V1::LeaderboardsTest < ActionDispatch::IntegrationTest
  setup do
    user = User.create!(
      email: "board@example.com",
      password: "password123",
      password_confirmation: "password123",
      city: "Istanbul",
      region: "Marmara"
    )
    @token = Auth::TokenIssuer.new.call(user: user).access_token
    LeaderboardSnapshot.create!(scope: "global", data: { total_territories: 4 })
    LeaderboardSnapshot.create!(scope: "city", scope_value: "Istanbul", data: { rankings: [{ user_id: user.id }] })
  end

  test "returns latest snapshot for scope" do
    get "/api/v1/leaderboards/global", headers: auth_headers(@token)

    assert_response :success
    assert_equal 4, response.parsed_body.dig("data", "total_territories")
  end

  test "returns location-scoped snapshot" do
    get "/api/v1/leaderboards/city",
        params: { scope_value: "Istanbul" },
        headers: auth_headers(@token)

    assert_response :success
    assert_equal "Istanbul", response.parsed_body["scope_value"]
  end

  private

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
