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

ActiveRecord::Schema[8.1].define(version: 2026_11_02_210300) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "game_rounds", force: :cascade do |t|
    t.bigint "game_session_id", null: false
    t.integer "number", null: false
    t.string "state", null: false
    t.jsonb "dealer_cards", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_session_id", "number"], name: "index_game_rounds_on_game_session_id_and_number", unique: true
  end

  create_table "game_seats", force: :cascade do |t|
    t.bigint "game_session_id", null: false
    t.integer "position", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_session_id", "position"], name: "index_game_seats_on_game_session_id_and_position", unique: true
  end

  create_table "game_sessions", force: :cascade do |t|
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "shoe_cards", default: [], null: false
    t.index ["status"], name: "index_game_sessions_on_status"
  end

  create_table "round_hands", force: :cascade do |t|
    t.bigint "game_round_id", null: false
    t.bigint "game_seat_id", null: false
    t.jsonb "cards", default: [], null: false
    t.string "status", null: false
    t.string "outcome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_round_id", "game_seat_id"], name: "index_round_hands_on_game_round_id_and_game_seat_id", unique: true
    t.index ["game_seat_id"], name: "index_round_hands_on_game_seat_id"
  end

  add_foreign_key "game_rounds", "game_sessions"
  add_foreign_key "game_seats", "game_sessions"
  add_foreign_key "round_hands", "game_rounds"
  add_foreign_key "round_hands", "game_seats"
end
