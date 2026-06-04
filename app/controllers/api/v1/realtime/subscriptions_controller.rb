module Api
  module V1
    module Realtime
      class SubscriptionsController < ApplicationController
        def nearby
          contract = Territories::SubscriptionContract.new.call(
            lat: params.require(:lat),
            lng: params.require(:lng),
            radius: params.fetch(:radius, 1),
            cable_url: "#{request.base_url}/cable"
          )

          render json: contract
        end
      end
    end
  end
end
