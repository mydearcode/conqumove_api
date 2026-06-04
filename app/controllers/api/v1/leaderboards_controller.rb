module Api
  module V1
    class LeaderboardsController < ApplicationController
      def show
        snapshot = LeaderboardSnapshot
                   .for_scope(params[:scope], params[:scope_value])
                   .recent_first
                   .first
        raise ActiveRecord::RecordNotFound, "Leaderboard snapshot not found" unless snapshot

        render json: {
          scope: snapshot.scope,
          scope_value: snapshot.scope_value,
          data: snapshot.data,
          created_at: snapshot.created_at
        }
      end
    end
  end
end
