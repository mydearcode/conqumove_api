require "test_helper"

class Leaderboards::SnapshotBuilderTest < ActiveSupport::TestCase
  test "builds global and user snapshots" do
    user = User.create!(
      email: "leader@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    Territory.create!(hex_id: "8928308280fffff", resolution: 9, owner: user, stability_score: 3.0, pressure_score: 1.0)
    Territory.create!(hex_id: "8928308280bffff", resolution: 9, stability_score: 1.5, pressure_score: 0.5)
    TerritoryEvent.create!(
      territory: Territory.first,
      user: user,
      event_type: :capture,
      payload: { new_owner_id: user.id }
    )
    device = user.devices.create!(device_identifier: "leader-ios", platform: "ios")
    user.movement_sessions.create!(
      device: device,
      activity_type: :walking,
      status: :ended,
      started_at: 1.hour.ago,
      ended_at: Time.current,
      total_distance_m: 1500,
      total_duration_sec: 1800,
      avg_speed_kmh: 3.0
    )

    global_snapshot = Leaderboards::SnapshotBuilder.new.call(scope: "global")
    user_snapshot = Leaderboards::SnapshotBuilder.new.call(scope: "user")

    assert_equal "global", global_snapshot.scope
    assert_equal 2, global_snapshot.data["total_territories"]
    assert_equal "user", user_snapshot.scope
    assert_equal user.id, user_snapshot.data["rankings"].first["user_id"]
  end
end
