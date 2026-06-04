module Api
  module V1
    module Admin
      class LeaderboardsController < BaseController
        def refresh
          scope = params.fetch(:scope, "global")
          LeaderboardSnapshotJob.perform_later(scope)

          render json: {
            accepted: true,
            scope: scope
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
