module Api
  module V1
    class TerritoriesController < ApplicationController
      def nearby
        territories = Territories::NearbyQuery.new.call(
          lat: params.require(:lat),
          lng: params.require(:lng),
          radius: params.fetch(:radius, 1),
          resolution: params.fetch(:resolution, Geo::H3Client::DEFAULT_RESOLUTION)
        )

        render json: territories.map { |territory| territory_payload(territory) }
      end

      private

      def public_rate_limit_config
        Rails.application.config.x.public_api_rate_limits.fetch(:territories).fetch(:nearby)
      end

      def territory_payload(territory)
        {
          hex_id: territory.hex_id,
          resolution: territory.resolution,
          owner_user_id: territory.owner_id,
          stability_score: territory.stability_score,
          pressure_score: territory.pressure_score,
          last_activity_at: territory.last_activity_at,
          version: territory.version
        }
      end
    end
  end
end
