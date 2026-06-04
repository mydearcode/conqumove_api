module Trust
  class TrustScoreCalculator
    WINDOW_PENALTY = 10

    def call(points:, activity_type:)
      score = 100
      score -= 30 if Trust::SpeedAnomalyDetector.new(points: points, activity_type: activity_type).suspicious?
      score -= 25 if Trust::GpsJumpDetector.new(points: points).jump_detected?
      score -= point_window_penalty(points: points, activity_type: activity_type)
      [score, 0].max
    end

    private

    def point_window_penalty(points:, activity_type:)
      suspicious_windows = Trust::PointWindowAnalyzer.new(
        points: points,
        activity_type: activity_type
      ).suspicious_windows

      suspicious_windows.count * WINDOW_PENALTY
    end
  end
end
