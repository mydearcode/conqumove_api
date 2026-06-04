module Territories
  class CaptureEngine
    def call(territory:, attacker:, movement_session:, batch_uuid:)
      return unless territory.pressure_score > territory.stability_score
      return if territory.owner_user_id == attacker.id

      previous_owner_id = territory.owner_user_id
      territory.update!(owner: attacker, last_capture_at: Time.current, version: territory.version + 1)

      Territories::EventAppender.new.call(
        territory: territory,
        event_type: :capture,
        user: attacker,
        movement_session: movement_session,
        batch_uuid: batch_uuid,
        payload: {
          previous_owner_id: previous_owner_id,
          new_owner_id: attacker.id,
          pressure_score: territory.pressure_score,
          stability_score: territory.stability_score
        }
      )

      BroadcastTerritoryUpdatesJob.perform_later(territory.id, "capture")
    end
  end
end
