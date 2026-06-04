module Movement
  class SessionStarter
    def call(user:, device_id:, activity_type:, platform: "ios")
      device = user.devices.find_or_initialize_by(device_identifier: device_id)
      device.platform = platform.presence || device.platform || "ios"
      device.last_seen_at = Time.current
      device.save!

      user.movement_sessions.create!(
        device: device,
        activity_type: activity_type,
        status: :active,
        started_at: Time.current,
        trust_score: 100
      )
    end
  end
end
