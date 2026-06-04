require "test_helper"
require "action_cable/test_helper"

class BroadcastTerritoryUpdatesJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test "broadcasts territory diff updates to hex stream" do
    territory = Territory.create!(
      hex_id: "8928308280fffff",
      resolution: 9,
      stability_score: 4.5,
      pressure_score: 2.0,
      version: 3
    )

    expected = {
      type: "influence_update",
      hex_id: territory.hex_id,
      resolution: 9,
      owner_user_id: nil,
      stability_score: 4.5,
      pressure_score: 2.0,
      version: 3,
      last_activity_at: nil,
      last_capture_at: nil
    }

    assert_broadcast_on("territory_updates:#{territory.hex_id}", expected) do
      BroadcastTerritoryUpdatesJob.perform_now(territory.id, "influence_update")
    end
  end
end
