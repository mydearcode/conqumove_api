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

    assert_difference("AdminActionLog.count", 1) do
      assert_enqueued_with(job: RebuildTerritoriesJob, args: [nil]) do
        post "/api/v1/admin/territories/rebuild",
             headers: auth_headers(token),
             as: :json
      end
    end

    assert_response :accepted
    assert_equal "accepted", AdminActionLog.order(:created_at).last.status
  end

  test "rate limits excessive rebuild requests" do
    admin = User.create!(
      email: "limited-admin@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: :admin
    )
    token = Auth::TokenIssuer.new.call(user: admin).access_token

    3.times do
      post "/api/v1/admin/territories/rebuild",
           headers: auth_headers(token),
           as: :json
      assert_response :accepted
    end

    post "/api/v1/admin/territories/rebuild",
         headers: auth_headers(token),
         as: :json

    assert_response :too_many_requests
    assert_equal "rate_limited", AdminActionLog.order(:created_at).last.status
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
