require "test_helper"
require "active_job/test_helper"

class Api::V1::MovementBatchesTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user = User.create!(
      email: "walker@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = ApiToken.issue_for(user: @user).last
    @device = @user.devices.create!(device_identifier: "ios-sim-2", platform: "ios")
    @session = @user.movement_sessions.create!(
      device: @device,
      activity_type: :walking,
      status: :active,
      started_at: Time.current,
      trust_score: 100
    )
  end

  test "accepts a movement batch and enqueues analysis" do
    assert_enqueued_with(job: AnalyzeMovementBatchJob, args: [@session.id, "batch-1"]) do
      post "/api/v1/movement/batch", params: {
        session_id: @session.id,
        idempotency_key: "batch-1",
        points: [
          { lat: 41.01, lng: 29.02, timestamp: Time.current.iso8601, speed: 5.1, accuracy: 8.0 },
          { lat: 41.011, lng: 29.021, timestamp: 5.seconds.from_now.iso8601, speed: 5.4, accuracy: 7.5 }
        ]
      }, headers: auth_headers(@token), as: :json
    end

    assert_response :accepted
    assert_equal 2, @session.gps_points.count
  end

  test "ignores duplicate movement batches" do
    2.times do
      post "/api/v1/movement/batch", params: {
        session_id: @session.id,
        idempotency_key: "batch-duplicate",
        points: [
          { lat: 41.01, lng: 29.02, timestamp: Time.current.iso8601, speed: 5.1, accuracy: 8.0 }
        ]
      }, headers: auth_headers(@token), as: :json
    end

    assert_response :ok
    assert_equal 1, @session.gps_points.count
  end

  private

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
