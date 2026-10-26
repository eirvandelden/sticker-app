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

ActiveRecord::Schema[8.1].define(version: 2026_08_19_084422) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "allowance_periods", force: :cascade do |t|
    t.integer "allowance_id", null: false
    t.date "due_on", null: false
    t.boolean "given", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["allowance_id", "due_on"], name: "index_allowance_periods_on_allowance_id_and_due_on", unique: true
  end

  create_table "allowances", force: :cascade do |t|
    t.integer "child_profile_id", null: false
    t.integer "kind", null: false
    t.integer "amount_cents", null: false
    t.integer "frequency", null: false
    t.integer "due_day", null: false
    t.date "next_due_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_profile_id", "kind"], name: "index_allowances_on_child_profile_id_and_kind", unique: true
  end

  create_table "appkit_push_subscriptions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "endpoint", null: false
    t.string "p256dh_key"
    t.string "auth_key"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["endpoint"], name: "index_appkit_push_subscriptions_on_endpoint", unique: true
    t.index ["user_id"], name: "index_appkit_push_subscriptions_on_user_id"
  end

  create_table "child_profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "sticker_goal", default: 10, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "birthdate"
    t.string "goal"
    t.index ["user_id"], name: "index_child_profiles_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "token", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_active_at"
    t.index ["token"], name: "index_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sticker_cards", force: :cascade do |t|
    t.integer "child_profile_id", null: false
    t.boolean "reward_given"
    t.boolean "completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "completed_at"
    t.integer "sticker_goal", default: 10, null: false
    t.string "goal"
    t.boolean "goal_overridden", default: false, null: false
    t.index ["child_profile_id"], name: "index_sticker_cards_on_child_profile_id"
    t.index ["completed_at"], name: "index_sticker_cards_on_completed_at"
  end

  create_table "stickers", force: :cascade do |t|
    t.integer "sticker_card_id", null: false
    t.integer "kind"
    t.string "emoji"
    t.string "note"
    t.integer "giver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sticker_card_id"], name: "index_stickers_on_sticker_card_id"
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
    t.boolean "active", default: true, null: false
    t.string "name", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "allowance_periods", "allowances"
  add_foreign_key "allowances", "child_profiles"
  add_foreign_key "appkit_push_subscriptions", "users"
  add_foreign_key "child_profiles", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "sticker_cards", "child_profiles"
  add_foreign_key "stickers", "sticker_cards"
end
