require "test_helper"

class Api::V1::TerritoriesTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "territories@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = Auth::TokenIssuer.new.call(user: @user).access_token

    territory = Territory.find_or_initialize_by(
      hex_id: Territories::HexResolver.new.call(lat: 41.015, lng: 28.979),
      resolution: Geo::H3Client::DEFAULT_RESOLUTION
    )
    territory.assign_attributes(
      owner: @user,
      stability_score: 8.5,
      pressure_score: 2.0,
      version: 2,
      last_activity_at: Time.current
    )
    territory.save!
  end

  test "returns nearby territories with owner_user_id payload" do
    get "/api/v1/territories/nearby",
        params: { lat: 41.015, lng: 28.979, radius: 0 },
        headers: auth_headers(@token)

    assert_response :success
    body = response.parsed_body
    assert_equal @user.id, body.first["owner_user_id"]
  end

  private

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
