module Territories
  class InfluenceEngine
    WALKING_STABILITY_PER_POINT = 1.0
    RUNNING_PRESSURE_FACTOR = 0.5

    def call(session:, points:, batch_uuid:, trust_score:)
      trust_factor = [trust_score.to_f / 100.0, 0.0].max
      grouped_points(points).each do |hex_id, hex_points|
        territory = Territory.find_or_create_by!(hex_id: hex_id, resolution: Geo::H3Client::DEFAULT_RESOLUTION)

        territory.with_lock do
          next if TerritoryEvent.exists?(territory: territory, batch_uuid: batch_uuid, event_type: :influence_applied)

          stability_delta, pressure_delta = deltas_for(session: session, points: hex_points, trust_factor: trust_factor)
          territory.stability_score += stability_delta
          territory.pressure_score += pressure_delta
          territory.last_activity_at = hex_points.max_by(&:recorded_at).recorded_at
          territory.version += 1
          territory.save!

          Territories::EventAppender.new.call(
            territory: territory,
            event_type: :influence_applied,
            user: session.user,
            movement_session: session,
            batch_uuid: batch_uuid,
            payload: {
              hex_id: territory.hex_id,
              stability_delta: stability_delta,
              pressure_delta: pressure_delta,
              trust_score: trust_score
            }
          )

          BroadcastTerritoryUpdatesJob.perform_later(territory.id, "influence_update")

          Territories::CaptureEngine.new.call(
            territory: territory,
            attacker: session.user,
            movement_session: session,
            batch_uuid: batch_uuid
          )
        end
      end
    end

    private

    def grouped_points(points)
      resolver = Territories::HexResolver.new
      points.group_by { |point| resolver.call(lat: point.lat, lng: point.lng) }
    end

    def deltas_for(session:, points:, trust_factor:)
      return [points.size * WALKING_STABILITY_PER_POINT * trust_factor, 0.0] if session.activity_walking?

      speeds = points.filter_map { |point| point.speed_kmh&.to_f }
      average_speed = speeds.sum / [speeds.size, 1].max
      [0.0, average_speed * points.size * RUNNING_PRESSURE_FACTOR * trust_factor]
    end
  end
end
