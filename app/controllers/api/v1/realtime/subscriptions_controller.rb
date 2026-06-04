module Api
  module V1
    module Realtime
      class SubscriptionsController < ApplicationController
        def nearby
          contract = Territories::SubscriptionContract.new.call(
            lat: params.require(:lat),
            lng: params.require(:lng),
            radius: params.fetch(:radius, 1),
            cable_url: public_cable_url
          )

          render json: contract
        end

        private

        def public_rate_limit_config
          Rails.application.config.x.public_api_rate_limits.fetch(:realtime_subscriptions).fetch(:nearby)
        end
      end
    end
  end
end
