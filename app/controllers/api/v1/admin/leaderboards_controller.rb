module Api
  module V1
    module Admin
      class LeaderboardsController < BaseController
        def refresh
          scope = params.fetch(:scope, "global")
          scope_value = params[:scope_value].presence
          LeaderboardSnapshotJob.perform_later(scope, scope_value)

          render json: {
            accepted: true,
            scope: scope,
            scope_value: scope_value
          }, status: :accepted
        end

        private

        def admin_rate_limit
          { limit: 10, period: 15.minutes }
        end
      end
    end
  end
end
