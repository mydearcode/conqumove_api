module Movement
  class SessionFinisher
    def call(session_id:, summary: {})
      session = MovementSession.find(session_id)
      summary = summary.to_h.symbolize_keys

      session.update!(
        status: :ended,
        ended_at: Time.current,
        total_distance_m: summary.fetch(:distance_m, session.total_distance_m),
        total_duration_sec: summary.fetch(:duration_sec, session.total_duration_sec),
        avg_speed_kmh: summary.fetch(:avg_speed_kmh, session.avg_speed_kmh)
      )

      session
    end
  end
end
