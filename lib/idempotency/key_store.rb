module Idempotency
  class KeyStore
    Result = Struct.new(:record, :created, keyword_init: true)

    def claim!(scope:, key:, request_fingerprint:)
      record = IdempotencyKey.find_by(scope: scope, key: key)
      return Result.new(record: record, created: false) if record

      record = IdempotencyKey.create!(
        scope: scope,
        key: key,
        request_fingerprint: request_fingerprint
      )

      Result.new(record: record, created: true)
    rescue ActiveRecord::RecordNotUnique
      Result.new(record: IdempotencyKey.find_by!(scope: scope, key: key), created: false)
    end
  end
end
