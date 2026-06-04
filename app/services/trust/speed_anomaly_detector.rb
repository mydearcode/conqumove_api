module Trust
  class SpeedAnomalyDetector
    WALKING_THRESHOLD_KMH = 12.0
    RUNNING_THRESHOLD_KMH = 28.0

    def initialize(points:, activity_type:)
      @points = points
      @activity_type = activity_type.to_s
    end

    def suspicious?
      threshold = @activity_type == "running" ? RUNNING_THRESHOLD_KMH : WALKING_THRESHOLD_KMH
      @points.any? { |point| point.speed_kmh.to_f > threshold }
    end
  end
end
