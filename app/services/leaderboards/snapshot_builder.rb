module Leaderboards
  class SnapshotBuilder
    SUPPORTED_SCOPES = %w[global user].freeze

    def call(scope:)
      raise ArgumentError, "Unsupported leaderboard scope" unless SUPPORTED_SCOPES.include?(scope.to_s)

      LeaderboardSnapshot.create!(
        scope: scope,
        data: send("#{scope}_snapshot")
      )
    end

    private

    def global_snapshot
      {
        total_territories: Territory.count,
        claimed_territories: Territory.where.not(owner_id: nil).count,
        captures: TerritoryEvent.capture.count,
        total_stability: Territory.sum(:stability_score),
        total_pressure: Territory.sum(:pressure_score)
      }
    end

    def user_snapshot
      rows = User.left_joins(:movement_sessions)
                 .select("users.id, users.email")
                 .distinct
                 .map do |user|
        {
          user_id: user.id,
          email: user.email,
          owned_hex_count: Territory.where(owner_id: user.id).count,
          captures: TerritoryEvent.capture.where(user_id: user.id).count,
          total_distance_m: MovementSession.where(user_id: user.id).sum(:total_distance_m)
        }
      end

      {
        generated_at: Time.current,
        rankings: rows.sort_by { |row| [-row[:owned_hex_count], -row[:captures], -row[:total_distance_m]] }
      }
    end
  end
end
