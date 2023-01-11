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

ActiveRecord::Schema.define(version: 2023_01_11_080440) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dms_products", force: :cascade do |t|
    t.jsonb "medical_sum"
    t.string "name"
    t.jsonb "price", array: true
    t.jsonb "program", array: true
    t.string "uid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "insurants", force: :cascade do |t|
    t.integer "telegram_id"
    t.string "step"
    t.string "first_name"
    t.string "last_name"
    t.string "father_name"
    t.string "gender"
    t.date "date_of_birth"
    t.string "phone"
    t.string "email"
    t.string "place_of_birth"
    t.string "serial_number_of_passport"
    t.date "issued"
    t.string "division_code"
    t.string "issued_by"
    t.string "registration_address"
    t.string "actual_residence"
    t.bigint "dms_product_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dms_product_id"], name: "index_insurants_on_dms_product_id"
  end

  create_table "policy_holders", force: :cascade do |t|
    t.string "name"
    t.integer "telegram_id"
    t.string "step"
    t.string "first_name"
    t.string "last_name"
    t.string "father_name"
    t.string "gender"
    t.date "date_of_birth"
    t.string "phone"
    t.string "email"
    t.string "place_of_birth"
    t.string "serial_number_of_passport"
    t.date "issued"
    t.string "division_code"
    t.string "issued_by"
    t.string "registration_address"
    t.string "actual_residence"
    t.bigint "dms_product_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dms_product_id"], name: "index_policy_holders_on_dms_product_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.integer "telegram_id"
    t.string "step"
    t.string "first_name"
    t.string "last_name"
    t.string "father_name"
    t.string "gender"
    t.date "date_of_birth"
    t.string "phone"
    t.string "email"
    t.bigint "dms_product_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dms_product_id"], name: "index_users_on_dms_product_id"
  end

  add_foreign_key "insurants", "dms_products"
  add_foreign_key "policy_holders", "dms_products"
  add_foreign_key "users", "dms_products"
end
