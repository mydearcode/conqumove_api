module Territories
  class EventAppender
    def call(territory:, event_type:, payload:, user: nil, movement_session: nil, batch_uuid: nil)
      TerritoryEvent.create!(
        territory: territory,
        user: user,
        movement_session: movement_session,
        event_type: event_type,
        batch_uuid: batch_uuid,
        payload: payload
      )
    rescue ActiveRecord::RecordNotUnique
      TerritoryEvent.find_by!(territory: territory, event_type: event_type, batch_uuid: batch_uuid)
    end
  end
end
