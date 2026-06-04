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
      end
    end
  end
end
