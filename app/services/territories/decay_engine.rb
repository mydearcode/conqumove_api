module Territories
  class DecayEngine
    STABILITY_DECAY_FACTOR = 0.98
    PRESSURE_DECAY_FACTOR = 0.95
    MIN_SCORE_THRESHOLD = 0.1

    def call(scope: Territory.all)
      scope.where("stability_score > 0 OR pressure_score > 0 OR owner_id IS NOT NULL").find_each do |territory|
        apply_decay(territory)
      end
    end

    private

    def apply_decay(territory)
      territory.with_lock do
        previous_stability = territory.stability_score
        previous_pressure = territory.pressure_score
        previous_owner_id = territory.owner_id

        territory.stability_score = decayed_score(previous_stability, STABILITY_DECAY_FACTOR)
        territory.pressure_score = decayed_score(previous_pressure, PRESSURE_DECAY_FACTOR)
        territory.owner = nil if neutralized?(territory)
        territory.version += 1
        territory.save!

        Territories::EventAppender.new.call(
          territory: territory,
          event_type: :decay_tick,
          payload: {
            previous_stability_score: previous_stability,
            previous_pressure_score: previous_pressure,
            current_stability_score: territory.stability_score,
            current_pressure_score: territory.pressure_score,
            previous_owner_id: previous_owner_id,
            current_owner_id: territory.owner_id
          }
        )

        BroadcastTerritoryUpdatesJob.perform_later(territory.id, "decay_tick")
      end
    end

    def decayed_score(score, factor)
      value = score.to_f * factor
      value < MIN_SCORE_THRESHOLD ? 0.0 : value
    end

    def neutralized?(territory)
      territory.stability_score.zero? && territory.pressure_score.zero?
    end
  end
end
