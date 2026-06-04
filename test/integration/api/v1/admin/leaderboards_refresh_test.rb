require "test_helper"
require "active_job/test_helper"

class Api::V1::Admin::LeaderboardsRefreshTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "enqueues leaderboard refresh and logs action" do
    admin = User.create!(
      email: "board-admin@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: :admin
    )
    token = Auth::TokenIssuer.new.call(user: admin).access_token

    assert_difference("AdminActionLog.count", 1) do
      assert_enqueued_with(job: LeaderboardSnapshotJob, args: ["global"]) do
        post "/api/v1/admin/leaderboards/refresh",
             params: { scope: "global" },
             headers: auth_headers(token),
             as: :json
      end
    end

    assert_response :accepted
    assert_equal "accepted", AdminActionLog.order(:created_at).last.status
  end

  private

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
