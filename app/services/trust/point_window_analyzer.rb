module Trust
  class PointWindowAnalyzer
    WINDOW_SIZE = 3

    def initialize(points:, activity_type:)
      @points = points
      @activity_type = activity_type
    end

    def suspicious_windows
      windows.select do |window|
        Trust::SpeedAnomalyDetector.new(points: window, activity_type: @activity_type).suspicious? ||
          Trust::GpsJumpDetector.new(points: window).jump_detected?
      end
    end

    private

    def windows
      return [] if @points.size < WINDOW_SIZE

      @points.each_cons(WINDOW_SIZE).to_a
    end
  end
end
