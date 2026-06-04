module Api
  module V1
    class LeaderboardsController < ApplicationController
      def show
        snapshot = LeaderboardSnapshot.where(scope: params[:scope]).recent_first.first
        raise ActiveRecord::RecordNotFound, "Leaderboard snapshot not found" unless snapshot

        render json: {
          scope: snapshot.scope,
          data: snapshot.data,
          created_at: snapshot.created_at
        }
      end
    end
  end
end
