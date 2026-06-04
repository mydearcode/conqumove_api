class CreateConqumoveCore < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :users, id: :uuid do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :devices, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :device_identifier, null: false
      t.string :platform, null: false, default: "ios"
      t.datetime :last_seen_at
      t.timestamps
    end
    add_index :devices, [:user_id, :device_identifier], unique: true

    create_table :movement_sessions, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :device, null: false, foreign_key: true, type: :uuid
      t.integer :activity_type, null: false
      t.integer :status, null: false, default: 0
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.float :total_distance_m, null: false, default: 0.0
      t.integer :total_duration_sec, null: false, default: 0
      t.float :avg_speed_kmh, null: false, default: 0.0
      t.integer :trust_score, null: false, default: 100
      t.string :invalid_reason
      t.timestamps
    end
    add_index :movement_sessions, [:user_id, :status]

    create_table :gps_points, id: :uuid do |t|
      t.references :movement_session, null: false, foreign_key: true, type: :uuid
      t.string :batch_uuid, null: false
      t.integer :sequence_no, null: false
      t.decimal :lat, precision: 10, scale: 6, null: false
      t.decimal :lng, precision: 10, scale: 6, null: false
      t.datetime :recorded_at, null: false
      t.float :speed_kmh
      t.float :accuracy_m
      t.string :source, null: false, default: "ios"
      t.timestamps
    end
    add_index :gps_points, [:movement_session_id, :batch_uuid, :sequence_no], unique: true
    add_index :gps_points, [:movement_session_id, :recorded_at]

    create_table :territories, id: :uuid do |t|
      t.string :hex_id, null: false
      t.integer :resolution, null: false, default: 9
      t.references :owner, null: true, foreign_key: { to_table: :users }, type: :uuid
      t.float :stability_score, null: false, default: 0.0
      t.float :pressure_score, null: false, default: 0.0
      t.datetime :last_activity_at
      t.datetime :last_capture_at
      t.integer :version, null: false, default: 0
      t.timestamps
    end
    add_index :territories, [:hex_id, :resolution], unique: true

    create_table :territory_events, id: :uuid do |t|
      t.references :territory, null: false, foreign_key: true, type: :uuid
      t.references :user, null: true, foreign_key: true, type: :uuid
      t.references :movement_session, null: true, foreign_key: true, type: :uuid
      t.integer :event_type, null: false
      t.string :batch_uuid
      t.jsonb :payload, null: false, default: {}
      t.timestamps
    end
    add_index :territory_events, [:territory_id, :event_type, :batch_uuid], unique: true, where: "batch_uuid IS NOT NULL"

    create_table :idempotency_keys, id: :uuid do |t|
      t.string :scope, null: false
      t.string :key, null: false
      t.string :request_fingerprint, null: false
      t.datetime :expires_at
      t.timestamps
    end
    add_index :idempotency_keys, [:scope, :key], unique: true
  end
end
