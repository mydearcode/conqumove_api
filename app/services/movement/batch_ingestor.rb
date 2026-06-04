require "digest"

module Movement
  class BatchIngestor
    Result = Struct.new(:batch_uuid, :accepted, :gps_points, keyword_init: true)

    def call(session:, points:, idempotency_key:)
      raise ArgumentError, "points must be present" if points.blank?
      raise ArgumentError, "idempotency_key must be present" if idempotency_key.blank?

      fingerprint = Digest::SHA256.hexdigest(points.to_json)
      claim = Idempotency::KeyStore.new.claim!(
        scope: "movement_batch:#{session.id}",
        key: idempotency_key,
        request_fingerprint: fingerprint
      )

      if !claim.created && claim.record.request_fingerprint != fingerprint
        raise ArgumentError, "idempotency key already used with different payload"
      end

      return Result.new(batch_uuid: idempotency_key, accepted: false, gps_points: []) unless claim.created

      gps_points = points.each_with_index.map do |point, index|
        session.gps_points.create!(
          batch_uuid: idempotency_key,
          sequence_no: index,
          lat: point.fetch(:lat),
          lng: point.fetch(:lng),
          recorded_at: point.fetch(:timestamp),
          speed_kmh: point[:speed],
          accuracy_m: point[:accuracy],
          source: point[:source] || "ios"
        )
      end

      AnalyzeMovementBatchJob.perform_later(session.id, idempotency_key)

      Result.new(batch_uuid: idempotency_key, accepted: true, gps_points: gps_points)
    end
  end
end
