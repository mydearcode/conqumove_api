# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_04_153500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "devices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "device_identifier", null: false
    t.datetime "last_seen_at"
    t.string "platform", default: "ios", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "device_identifier"], name: "index_devices_on_user_id_and_device_identifier", unique: true
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "gps_points", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.float "accuracy_m"
    t.string "batch_uuid", null: false
    t.datetime "created_at", null: false
    t.decimal "lat", precision: 10, scale: 6, null: false
    t.decimal "lng", precision: 10, scale: 6, null: false
    t.uuid "movement_session_id", null: false
    t.datetime "recorded_at", null: false
    t.integer "sequence_no", null: false
    t.string "source", default: "ios", null: false
    t.float "speed_kmh"
    t.datetime "updated_at", null: false
    t.index ["movement_session_id", "batch_uuid", "sequence_no"], name: "idx_on_movement_session_id_batch_uuid_sequence_no_4a5b62e272", unique: true
    t.index ["movement_session_id", "recorded_at"], name: "index_gps_points_on_movement_session_id_and_recorded_at"
    t.index ["movement_session_id"], name: "index_gps_points_on_movement_session_id"
  end

  create_table "idempotency_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "key", null: false
    t.string "request_fingerprint", null: false
    t.string "scope", null: false
    t.datetime "updated_at", null: false
    t.index ["scope", "key"], name: "index_idempotency_keys_on_scope_and_key", unique: true
  end

  create_table "movement_sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "activity_type", null: false
    t.float "avg_speed_kmh", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.uuid "device_id", null: false
    t.datetime "ended_at"
    t.string "invalid_reason"
    t.datetime "started_at", null: false
    t.integer "status", default: 0, null: false
    t.float "total_distance_m", default: 0.0, null: false
    t.integer "total_duration_sec", default: 0, null: false
    t.integer "trust_score", default: 100, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["device_id"], name: "index_movement_sessions_on_device_id"
    t.index ["user_id", "status"], name: "index_movement_sessions_on_user_id_and_status"
    t.index ["user_id"], name: "index_movement_sessions_on_user_id"
  end

  create_table "territories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hex_id", null: false
    t.datetime "last_activity_at"
    t.datetime "last_capture_at"
    t.uuid "owner_id"
    t.float "pressure_score", default: 0.0, null: false
    t.integer "resolution", default: 9, null: false
    t.float "stability_score", default: 0.0, null: false
    t.datetime "updated_at", null: false
    t.integer "version", default: 0, null: false
    t.index ["hex_id", "resolution"], name: "index_territories_on_hex_id_and_resolution", unique: true
    t.index ["owner_id"], name: "index_territories_on_owner_id"
  end

  create_table "territory_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "batch_uuid"
    t.datetime "created_at", null: false
    t.integer "event_type", null: false
    t.uuid "movement_session_id"
    t.jsonb "payload", default: {}, null: false
    t.uuid "territory_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["movement_session_id"], name: "index_territory_events_on_movement_session_id"
    t.index ["territory_id", "event_type", "batch_uuid"], name: "idx_on_territory_id_event_type_batch_uuid_a83eefb8c5", unique: true, where: "(batch_uuid IS NOT NULL)"
    t.index ["territory_id"], name: "index_territory_events_on_territory_id"
    t.index ["user_id"], name: "index_territory_events_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "devices", "users"
  add_foreign_key "gps_points", "movement_sessions"
  add_foreign_key "movement_sessions", "devices"
  add_foreign_key "movement_sessions", "users"
  add_foreign_key "territories", "users", column: "owner_id"
  add_foreign_key "territory_events", "movement_sessions"
  add_foreign_key "territory_events", "territories"
  add_foreign_key "territory_events", "users"
end
