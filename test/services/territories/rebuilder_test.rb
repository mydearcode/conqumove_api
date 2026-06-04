require "test_helper"

class Territories::RebuilderTest < ActiveSupport::TestCase
  test "rebuilds territory read model from domain events" do
    old_owner = User.create!(
      email: "old-owner@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    new_owner = User.create!(
      email: "new-owner@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    territory = Territory.create!(
      hex_id: "8928308280fffff",
      resolution: 9,
      owner: old_owner,
      stability_score: 999.0,
      pressure_score: 999.0,
      version: 10
    )

    territory.territory_events.create!(
      event_type: :influence_applied,
      payload: {
        stability_delta: 4.0,
        pressure_delta: 1.5
      }
    )
    territory.territory_events.create!(
      event_type: :capture,
      user: new_owner,
      payload: {
        new_owner_id: new_owner.id
      }
    )
    territory.territory_events.create!(
      event_type: :decay_tick,
      payload: {
        current_stability_score: 3.92,
        current_pressure_score: 1.425,
        current_owner_id: new_owner.id
      }
    )

    Territories::Rebuilder.new.call(territory: territory)

    territory.reload
    assert_in_delta 3.92, territory.stability_score, 0.001
    assert_in_delta 1.425, territory.pressure_score, 0.001
    assert_equal new_owner.id, territory.owner_id
    assert_equal 3, territory.version
  end
end
