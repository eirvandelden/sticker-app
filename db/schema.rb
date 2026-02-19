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

ActiveRecord::Schema[8.0].define(version: 2026_02_19_095214) do
  create_table "child_profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "sticker_goal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "user_id" ], name: "index_child_profiles_on_user_id"
  end

  create_table "faultline_error_contexts", force: :cascade do |t|
    t.integer "error_occurrence_id", null: false
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "error_occurrence_id", "key" ], name: "index_faultline_error_contexts_on_error_occurrence_id_and_key"
    t.index [ "error_occurrence_id" ], name: "index_faultline_error_contexts_on_error_occurrence_id"
  end

  create_table "faultline_error_groups", force: :cascade do |t|
    t.string "fingerprint", null: false
    t.string "exception_class", null: false
    t.text "sanitized_message", null: false
    t.string "file_path"
    t.integer "line_number"
    t.string "method_name"
    t.integer "occurrences_count", default: 0
    t.datetime "first_seen_at"
    t.datetime "last_seen_at"
    t.string "status", default: "unresolved"
    t.datetime "resolved_at"
    t.datetime "last_notified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "exception_class" ], name: "index_faultline_error_groups_on_exception_class"
    t.index [ "fingerprint" ], name: "index_faultline_error_groups_on_fingerprint", unique: true
    t.index [ "last_seen_at" ], name: "index_faultline_error_groups_on_last_seen_at"
    t.index [ "status" ], name: "index_faultline_error_groups_on_status"
  end

  create_table "faultline_error_occurrences", force: :cascade do |t|
    t.integer "error_group_id", null: false
    t.string "exception_class", null: false
    t.text "message", null: false
    t.text "backtrace"
    t.string "request_method"
    t.string "request_url"
    t.text "request_params"
    t.text "request_headers"
    t.string "user_agent"
    t.string "ip_address"
    t.bigint "user_id"
    t.string "user_type"
    t.string "session_id"
    t.string "environment"
    t.string "hostname"
    t.string "process_id"
    t.json "local_variables"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "created_at" ], name: "index_faultline_error_occurrences_on_created_at"
    t.index [ "error_group_id", "created_at" ], name: "idx_on_error_group_id_created_at_98b32c40ac"
    t.index [ "error_group_id" ], name: "index_faultline_error_occurrences_on_error_group_id"
    t.index [ "user_type", "user_id" ], name: "index_faultline_error_occurrences_on_user_type_and_user_id"
  end

  create_table "faultline_request_profiles", force: :cascade do |t|
    t.integer "request_trace_id", null: false
    t.text "profile_data", null: false
    t.string "mode", default: "cpu"
    t.integer "samples", default: 0
    t.float "interval_ms"
    t.datetime "created_at", null: false
    t.index [ "request_trace_id" ], name: "index_faultline_request_profiles_on_request_trace_id"
  end

  create_table "faultline_request_traces", force: :cascade do |t|
    t.string "endpoint", null: false
    t.string "http_method", null: false
    t.string "path"
    t.integer "status"
    t.float "duration_ms"
    t.float "db_runtime_ms"
    t.float "view_runtime_ms"
    t.integer "db_query_count", default: 0
    t.datetime "created_at", null: false
    t.json "spans"
    t.boolean "has_profile", default: false
    t.index [ "created_at" ], name: "index_faultline_request_traces_on_created_at"
    t.index [ "endpoint", "created_at" ], name: "index_faultline_request_traces_on_endpoint_and_created_at"
    t.index [ "endpoint" ], name: "index_faultline_request_traces_on_endpoint"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "token", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "token" ], name: "index_sessions_on_token", unique: true
    t.index [ "user_id" ], name: "index_sessions_on_user_id"
  end

  create_table "sticker_cards", force: :cascade do |t|
    t.integer "child_profile_id", null: false
    t.boolean "reward_given"
    t.boolean "completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "completed_at"
    t.index [ "child_profile_id" ], name: "index_sticker_cards_on_child_profile_id"
    t.index [ "completed_at" ], name: "index_sticker_cards_on_completed_at"
  end

  create_table "stickers", force: :cascade do |t|
    t.integer "sticker_card_id", null: false
    t.integer "kind"
    t.string "emoji"
    t.string "note"
    t.integer "giver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "sticker_card_id" ], name: "index_stickers_on_sticker_card_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "locale", default: "en", null: false
    t.integer "color_scheme", default: 0, null: false
    t.integer "light_theme", default: 1, null: false
    t.integer "dark_theme", default: 1, null: false
  end

  add_foreign_key "child_profiles", "users"
  add_foreign_key "faultline_error_contexts", "faultline_error_occurrences", column: "error_occurrence_id"
  add_foreign_key "faultline_error_occurrences", "faultline_error_groups", column: "error_group_id"
  add_foreign_key "faultline_request_profiles", "faultline_request_traces", column: "request_trace_id", on_delete: :cascade
  add_foreign_key "sessions", "users"
  add_foreign_key "sticker_cards", "child_profiles"
  add_foreign_key "stickers", "sticker_cards"
end
