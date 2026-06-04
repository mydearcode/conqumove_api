module Api
  module V1
    class MovementBatchesController < ApplicationController
      def create
        session = MovementSession.find(batch_params[:session_id])
        points = normalized_points
        result = Movement::BatchIngestor.new.call(
          session: session,
          points: points,
          idempotency_key: batch_params[:idempotency_key]
        )

        render json: {
          session_id: session.id,
          batch_uuid: result.batch_uuid,
          accepted: result.accepted,
          points_received: points.size
        }, status: result.accepted ? :accepted : :ok
      end

      private

      def batch_params
        params.permit(:session_id, :idempotency_key, points: [:lat, :lng, :timestamp, :speed, :accuracy, :source])
      end

      def normalized_points
        Array(batch_params[:points]).map do |point|
          point.to_h.symbolize_keys
        end
      end
    end
  end
end
