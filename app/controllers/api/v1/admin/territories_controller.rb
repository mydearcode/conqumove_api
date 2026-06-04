module Api
  module V1
    module Admin
      class TerritoriesController < BaseController
        def rebuild
          RebuildTerritoriesJob.perform_later(params[:territory_id].presence)

          render json: {
            accepted: true,
            territory_id: params[:territory_id].presence
          }, status: :accepted
        end
      end
    end
  end
end
