module Leaderboards
  class SnapshotBuilder
    SUPPORTED_SCOPES = %w[global user city region].freeze

    def call(scope:, scope_value: nil)
      raise ArgumentError, "Unsupported leaderboard scope" unless SUPPORTED_SCOPES.include?(scope.to_s)
      ensure_scope_value!(scope, scope_value)

      LeaderboardSnapshot.create!(
        scope: scope,
        scope_value: scope_value.presence,
        data: send("#{scope}_snapshot", scope_value)
      )
    end

    private

    def global_snapshot(_scope_value = nil)
      {
        total_territories: Territory.count,
        claimed_territories: Territory.where.not(owner_id: nil).count,
        captures: TerritoryEvent.capture.count,
        total_stability: Territory.sum(:stability_score),
        total_pressure: Territory.sum(:pressure_score)
      }
    end

    def user_snapshot(_scope_value = nil)
      {
        generated_at: Time.current,
        rankings: rankings_for(User.all)
      }
    end

    def city_snapshot(scope_value)
      users = User.where(city: scope_value)
      {
        generated_at: Time.current,
        city: scope_value,
        rankings: rankings_for(users)
      }
    end

    def region_snapshot(scope_value)
      users = User.where(region: scope_value)
      {
        generated_at: Time.current,
        region: scope_value,
        rankings: rankings_for(users)
      }
    end

    def rankings_for(users)
      users.select(:id, :email, :city, :region).map do |user|
        {
          user_id: user.id,
          email: user.email,
          city: user.city,
          region: user.region,
          owned_hex_count: Territory.where(owner_id: user.id).count,
          captures: TerritoryEvent.capture.where(user_id: user.id).count,
          total_distance_m: MovementSession.where(user_id: user.id).sum(:total_distance_m)
        }
      end.sort_by { |row| [-row[:owned_hex_count], -row[:captures], -row[:total_distance_m]] }
    end

    def ensure_scope_value!(scope, scope_value)
      return unless %w[city region].include?(scope.to_s)
      raise ArgumentError, "scope_value is required" if scope_value.blank?
    end
  end
end
