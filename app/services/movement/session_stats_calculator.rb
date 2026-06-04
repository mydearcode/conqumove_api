module Movement
  class SessionStatsCalculator
    EARTH_RADIUS_M = 6_371_000

    def call(session:)
      points = session.gps_points.ordered.to_a
      distance_m = total_distance(points)
      duration_sec = total_duration(points)
      avg_speed_kmh = duration_sec.positive? ? (distance_m / duration_sec) * 3.6 : 0.0

      session.update!(
        total_distance_m: distance_m,
        total_duration_sec: duration_sec,
        avg_speed_kmh: avg_speed_kmh
      )
    end

    private

    def total_distance(points)
      points.each_cons(2).sum { |from, to| distance_between(from, to) }
    end

    def total_duration(points)
      return 0 if points.size < 2

      (points.last.recorded_at - points.first.recorded_at).to_i
    end

    def distance_between(from, to)
      lat1 = radians(from.lat)
      lat2 = radians(to.lat)
      delta_lat = radians(to.lat - from.lat)
      delta_lng = radians(to.lng - from.lng)

      a = Math.sin(delta_lat / 2)**2 +
          Math.cos(lat1) * Math.cos(lat2) * Math.sin(delta_lng / 2)**2
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

      EARTH_RADIUS_M * c
    end

    def radians(value)
      value.to_f * Math::PI / 180
    end
  end
end
