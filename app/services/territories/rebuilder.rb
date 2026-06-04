module Territories
  class Rebuilder
    def call(territory: nil)
      territories = territory ? Array(territory) : Territory.includes(:territory_events).all
      territories.each { |record| rebuild_territory(record) }
    end

    private

    def rebuild_territory(territory)
      territory.with_lock do
        territory.update_columns(
          owner_id: nil,
          stability_score: 0.0,
          pressure_score: 0.0,
          last_activity_at: nil,
          last_capture_at: nil,
          version: 0,
          updated_at: Time.current
        )

        territory.territory_events.order(:created_at, :id).each do |event|
          apply_event(territory, event)
        end

        territory.save!
      end
    end

    def apply_event(territory, event)
      payload = event.payload.with_indifferent_access

      case event.event_type.to_sym
      when :influence_applied
        territory.stability_score += payload[:stability_delta].to_f
        territory.pressure_score += payload[:pressure_delta].to_f
        territory.last_activity_at = event.created_at
      when :capture
        territory.owner_id = payload[:new_owner_id]
        territory.last_capture_at = event.created_at
      when :decay_tick
        territory.stability_score = payload[:current_stability_score].to_f
        territory.pressure_score = payload[:current_pressure_score].to_f
        territory.owner_id = payload[:current_owner_id]
      end

      territory.version += 1
    end
  end
end
