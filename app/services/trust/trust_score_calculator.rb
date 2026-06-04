module Trust
  class TrustScoreCalculator
    def call(points:, activity_type:)
      score = 100
      score -= 30 if Trust::SpeedAnomalyDetector.new(points: points, activity_type: activity_type).suspicious?
      score -= 25 if Trust::GpsJumpDetector.new(points: points).jump_detected?
      [score, 0].max
    end
  end
end
