require "test_helper"
require "active_job/test_helper"

class Api::V1::Admin::TerritoriesRebuildTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "enqueues rebuild for admin user" do
    admin = User.create!(
      email: "admin@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: :admin
    )
    token = Auth::TokenIssuer.new.call(user: admin).access_token

    assert_enqueued_with(job: RebuildTerritoriesJob, args: [nil]) do
      post "/api/v1/admin/territories/rebuild",
           headers: auth_headers(token),
           as: :json
    end

    assert_response :accepted
  end

  test "rejects non-admin user" do
    player = User.create!(
      email: "player@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    token = Auth::TokenIssuer.new.call(user: player).access_token

    post "/api/v1/admin/territories/rebuild",
         headers: auth_headers(token),
         as: :json

    assert_response :forbidden
  end

  test "rejects unauthenticated request" do
    post "/api/v1/admin/territories/rebuild", as: :json

    assert_response :unauthorized
  end

  private

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
