class LeaderboardSnapshotJob < ApplicationJob
  queue_as :default

  def perform(scope = "global", scope_value = nil)
    Leaderboards::SnapshotBuilder.new.call(scope: scope, scope_value: scope_value)
  end
end
