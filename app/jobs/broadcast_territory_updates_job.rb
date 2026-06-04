class BroadcastTerritoryUpdatesJob < ApplicationJob
  queue_as :default

  def perform(territory_id, reason)
    territory = Territory.find(territory_id)
    payload = territory_payload(territory, reason)

    ActionCable.server.broadcast("territory_updates:#{territory.hex_id}", payload)

    return unless reason == "capture"

    ActionCable.server.broadcast(
      "capture_events:#{territory.hex_id}",
      payload.merge(type: "territory_captured")
    )
  end

  private

  def territory_payload(territory, reason)
    {
      type: reason,
      hex_id: territory.hex_id,
      resolution: territory.resolution,
      owner_user_id: territory.owner_id,
      stability_score: territory.stability_score,
      pressure_score: territory.pressure_score,
      version: territory.version,
      last_activity_at: territory.last_activity_at,
      last_capture_at: territory.last_capture_at
    }
  end
end
