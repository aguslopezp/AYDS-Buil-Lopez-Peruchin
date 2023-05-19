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

ActiveRecord::Schema[7.0].define(version: 2023_05_19_031455) do
  create_table "answers", force: :cascade do |t|
    t.integer "user_id"
    t.integer "option_id"
    t.index ["option_id"], name: "index_answers_on_option_id"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "asked_questions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "question_id"
    t.index ["question_id"], name: "index_asked_questions_on_question_id"
    t.index ["user_id"], name: "index_asked_questions_on_user_id"
  end

  create_table "options", force: :cascade do |t|
    t.string "description"
    t.boolean "isCorrect"
    t.integer "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_options_on_question_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password"
    t.string "email"
    t.date "birthdate"
    t.integer "points"
    t.integer "ranking_position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "answers", "options"
  add_foreign_key "answers", "users"
  add_foreign_key "asked_questions", "questions"
  add_foreign_key "asked_questions", "users"
  add_foreign_key "options", "questions"
end
