require "test_helper"

class Territories::DecayEngineTest < ActiveSupport::TestCase
  test "decays scores and appends decay event" do
    user = User.create!(
      email: "decay@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    territory = Territory.create!(
      hex_id: "8928308280fffff",
      resolution: 9,
      owner: user,
      stability_score: 10.0,
      pressure_score: 5.0,
      version: 2
    )

    assert_difference("territory.territory_events.count", 1) do
      Territories::DecayEngine.new.call(scope: Territory.where(id: territory.id))
    end

    territory.reload
    assert_in_delta 9.8, territory.stability_score, 0.001
    assert_in_delta 4.75, territory.pressure_score, 0.001
    assert_equal :decay_tick, territory.territory_events.last.event_type.to_sym
  end
end
