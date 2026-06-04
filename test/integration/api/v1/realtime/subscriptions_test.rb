require "test_helper"

class Api::V1::Realtime::SubscriptionsTest < ActionDispatch::IntegrationTest
  setup do
    host! "localhost"
    user = User.create!(
      email: "realtime@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = Auth::TokenIssuer.new.call(user: user).access_token
  end

  test "returns nearby subscription contract" do
    get "/api/v1/realtime/subscriptions/nearby",
        params: { lat: 41.01, lng: 29.02, radius: 1 },
        headers: auth_headers(@token)

    assert_response :success
    body = response.parsed_body
    assert_equal "http://localhost/cable", body["cable_url"]
    assert body["hex_ids"].any?
    assert_equal "TerritoryUpdatesChannel", body.dig("channels", "territory_updates", "channel")
  end

  private

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
