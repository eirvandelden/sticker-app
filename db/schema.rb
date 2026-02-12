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

ActiveRecord::Schema[8.0].define(version: 2026_02_12_120002) do
  create_table "child_profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "sticker_goal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_child_profiles_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "token", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  end

  add_foreign_key "child_profiles", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "sticker_cards", "child_profiles"
  add_foreign_key "stickers", "sticker_cards"
end
