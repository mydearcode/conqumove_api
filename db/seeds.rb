demo_password = "password123"
center_lat = 41.015
center_lng = 28.979
resolution = Geo::H3Client::DEFAULT_RESOLUTION

demo_user = User.find_or_initialize_by(email: "demo@conqumove.local")
demo_user.assign_attributes(
  password: demo_password,
  password_confirmation: demo_password,
  city: "Istanbul",
  region: "Marmara",
  role: :player
)
demo_user.save!

rival_user = User.find_or_initialize_by(email: "rival@conqumove.local")
rival_user.assign_attributes(
  password: demo_password,
  password_confirmation: demo_password,
  city: "Istanbul",
  region: "Marmara",
  role: :player
)
rival_user.save!

admin_user = User.find_or_initialize_by(email: "admin@conqumove.local")
admin_user.assign_attributes(
  password: demo_password,
  password_confirmation: demo_password,
  city: "Istanbul",
  region: "Marmara",
  role: :admin
)
admin_user.save!

demo_device = demo_user.devices.find_or_initialize_by(device_identifier: "ios-demo-device")
demo_device.platform = :ios
demo_device.last_seen_at = Time.current
demo_device.save!

demo_session = demo_user.movement_sessions.where(device: demo_device).order(created_at: :desc).first_or_initialize
demo_session.assign_attributes(
  activity_type: :walking,
  status: :ended,
  started_at: 20.minutes.ago,
  ended_at: 5.minutes.ago,
  total_distance_m: 1850.0,
  total_duration_sec: 900,
  avg_speed_kmh: 4.8,
  trust_score: 96
)
demo_session.save!

center_hex = Geo::H3Client.geo_to_h3(lat: center_lat, lng: center_lng, resolution: resolution)
hex_ids = Geo::H3Client.grid_disk(hex_id: center_hex, radius: 1).sort
owners = [demo_user, demo_user, rival_user, rival_user, nil, demo_user, rival_user]

hex_ids.each_with_index do |hex_id, index|
  owner = owners[index] || nil
  stability = 12.0 + index
  pressure = owner == rival_user ? 9.5 + index : 4.0 + index
  captured_at = owner.present? ? (index + 1).minutes.ago : nil

  territory = Territory.find_or_initialize_by(hex_id: hex_id, resolution: resolution)
  territory.assign_attributes(
    owner: owner,
    stability_score: stability,
    pressure_score: pressure,
    version: index + 1,
    last_activity_at: 2.minutes.ago,
    last_capture_at: captured_at
  )
  territory.save!

  territory.territory_events.delete_all

  territory.territory_events.create!(
    event_type: :influence_applied,
    user: owner || demo_user,
    movement_session: demo_session,
    batch_uuid: "seed-batch-#{index}",
    payload: {
      hex_id: hex_id,
      stability_delta: stability,
      pressure_delta: pressure,
      seeded: true
    }
  )

  next unless owner

  territory.territory_events.create!(
    event_type: :capture,
    user: owner,
    movement_session: demo_session,
    payload: {
      hex_id: hex_id,
      owner_user_id: owner.id,
      seeded: true
    }
  )
end

LeaderboardSnapshot.delete_all
Leaderboards::SnapshotBuilder.new.call(scope: "global")
Leaderboards::SnapshotBuilder.new.call(scope: "user")
Leaderboards::SnapshotBuilder.new.call(scope: "city", scope_value: "Istanbul")
Leaderboards::SnapshotBuilder.new.call(scope: "region", scope_value: "Marmara")

puts "Seeded Conqumove demo data"
puts "Player: demo@conqumove.local / #{demo_password}"
puts "Rival: rival@conqumove.local / #{demo_password}"
puts "Admin: admin@conqumove.local / #{demo_password}"
puts "Nearby test coordinates: lat=#{center_lat}, lng=#{center_lng}"
#   end
