class AnalyzeMovementBatchJob < ApplicationJob
  queue_as :default

  def perform(session_id, batch_uuid)
    session = MovementSession.find(session_id)
    points = session.gps_points.for_batch(batch_uuid).ordered.to_a
    return if points.empty?

    batch_trust_score = Trust::TrustScoreCalculator.new.call(
      points: points,
      activity_type: session.activity_type
    )

    Movement::SessionStatsCalculator.new.call(session: session)
    session.update!(trust_score: [session.trust_score.to_i, batch_trust_score].min)

    ApplyTerritoryInfluenceJob.perform_later(session.id, batch_uuid, batch_trust_score)
  end
end
