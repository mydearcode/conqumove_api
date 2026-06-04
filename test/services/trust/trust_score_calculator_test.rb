require "test_helper"

class Trust::TrustScoreCalculatorTest < ActiveSupport::TestCase
  Point = Struct.new(:lat, :lng, :recorded_at, :speed_kmh, keyword_init: true)

  test "applies extra penalty for suspicious point windows" do
    points = [
      Point.new(lat: 41.0, lng: 29.0, recorded_at: Time.current, speed_kmh: 5.0),
      Point.new(lat: 41.001, lng: 29.001, recorded_at: 5.seconds.from_now, speed_kmh: 5.2),
      Point.new(lat: 41.5, lng: 29.5, recorded_at: 10.seconds.from_now, speed_kmh: 45.0),
      Point.new(lat: 41.501, lng: 29.501, recorded_at: 15.seconds.from_now, speed_kmh: 4.8)
    ]

    score = Trust::TrustScoreCalculator.new.call(points: points, activity_type: :walking)

    assert_operator score, :<, 45
  end
end
