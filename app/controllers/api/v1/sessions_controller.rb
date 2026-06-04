module Api
  module V1
    class SessionsController < ApplicationController
      def start
        session = Movement::SessionStarter.new.call(
          user: current_user,
          device_id: start_params[:device_id],
          activity_type: start_params[:activity_type],
          platform: start_params[:platform]
        )

        render json: session_payload(session), status: :created
      end

      def finish
        session = current_user.movement_sessions.find(finish_params[:session_id])
        session = Movement::SessionFinisher.new.call(
          session: session,
          summary: finish_params[:summary] || {}
        )

        render json: session_payload(session)
      end

      private

      def public_rate_limit_config
        Rails.application.config.x.public_api_rate_limits.fetch(:sessions).fetch(action_name.to_sym, nil)
      end

      def start_params
        params.permit(:device_id, :activity_type, :platform)
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
