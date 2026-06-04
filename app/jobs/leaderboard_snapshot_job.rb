class LeaderboardSnapshotJob < ApplicationJob
  queue_as :default

  def perform(scope = "global")
    Leaderboards::SnapshotBuilder.new.call(scope: scope)
  end
end
