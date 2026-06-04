module Api
  module V1
    class SessionsController < ApplicationController
      def start
        session = Movement::SessionStarter.new.call(
          user_id: start_params[:user_id],
          device_id: start_params[:device_id],
          activity_type: start_params[:activity_type],
          platform: start_params[:platform]
        )

        render json: session_payload(session), status: :created
      end

      def finish
        session = Movement::SessionFinisher.new.call(
          session_id: finish_params[:session_id],
          summary: finish_params[:summary] || {}
        )

        render json: session_payload(session)
      end

      private

      def start_params
        params.permit(:user_id, :device_id, :activity_type, :platform)
      end

      def finish_params
        params.permit(:session_id, summary: [:distance_m, :duration_sec, :avg_speed_kmh])
      end

      def session_payload(session)
        {
          id: session.id,
          user_id: session.user_id,
          device_id: session.device_id,
          activity_type: session.activity_type,
          status: session.status,
          started_at: session.started_at,
          ended_at: session.ended_at,
          total_distance_m: session.total_distance_m,
          total_duration_sec: session.total_duration_sec,
          avg_speed_kmh: session.avg_speed_kmh,
          trust_score: session.trust_score
        }
      end
    end
  end
end
