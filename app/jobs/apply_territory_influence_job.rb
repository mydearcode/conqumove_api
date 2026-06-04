class ApplyTerritoryInfluenceJob < ApplicationJob
  queue_as :default

  def perform(session_id, batch_uuid, trust_score)
    session = MovementSession.find(session_id)
    points = session.gps_points.for_batch(batch_uuid).ordered.to_a
    return if points.empty?

    Territories::InfluenceEngine.new.call(
      session: session,
      points: points,
      batch_uuid: batch_uuid,
      trust_score: trust_score
    )
  end
end
