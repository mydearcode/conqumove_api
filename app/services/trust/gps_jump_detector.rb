module Trust
  class GpsJumpDetector
    EARTH_RADIUS_M = 6_371_000
    MAX_IMPLIED_SPEED_KMH = 80.0

    def initialize(points:)
      @points = points.sort_by(&:recorded_at)
    end

    def jump_detected?
      @points.each_cons(2).any? do |from, to|
        duration_hours = (to.recorded_at - from.recorded_at).to_f / 3600.0
        next false if duration_hours <= 0

        distance_km = distance_between(from, to) / 1000.0
        (distance_km / duration_hours) > MAX_IMPLIED_SPEED_KMH
      end
    end

    private

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
