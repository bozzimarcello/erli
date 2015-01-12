# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150112053410) do

  create_table "apartment_repartition_tables", force: true do |t|
    t.integer  "apartment_id"
    t.integer  "repartition_table_id"
    t.decimal  "percentage"
    t.integer  "floor"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apartment_repartition_tables", ["apartment_id"], name: "index_apartment_repartition_tables_on_apartment_id", using: :btree
  add_index "apartment_repartition_tables", ["repartition_table_id"], name: "index_apartment_repartition_tables_on_repartition_table_id", using: :btree

  create_table "apartments", force: true do |t|
    t.string   "name"
    t.integer  "rooms"
    t.integer  "building_id"
    t.integer  "dimension"
    t.integer  "floor"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "asset_expenses", force: true do |t|
    t.integer  "asset_id"
    t.string   "asset_type"
    t.integer  "expense_id"
    t.decimal  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "balance_dates", force: true do |t|
    t.integer  "building_id"
    t.date     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bollo_ranges", force: true do |t|
    t.integer  "from"
    t.integer  "to"
    t.decimal  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bollos", force: true do |t|
    t.integer  "identifier"
    t.decimal  "price"
    t.integer  "invoice_id"
    t.integer  "bollo_range_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "buildings", force: true do |t|
    t.string   "name"
    t.text     "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contracts", force: true do |t|
    t.string   "name"
    t.decimal  "istat"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expenses", force: true do |t|
    t.string   "name"
    t.string   "kind"
    t.boolean  "add_to_invoice"
    t.boolean  "add_to_conguaglio"
    t.integer  "building_id"
    t.integer  "repartition_table_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "balance_date_id"
  end

  create_table "google_tokens", force: true do |t|
    t.string   "access_token"
    t.string   "refresh_token"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leases", force: true do |t|
    t.decimal  "percentage",          default: 0.0, null: false
    t.integer  "contract_id"
    t.integer  "apartment_id"
    t.string   "invoice_address"
    t.date     "start_date"
    t.date     "end_date"
    t.decimal  "amount"
    t.integer  "payment_frequency"
    t.decimal  "deposit"
    t.date     "registration_date"
    t.integer  "registration_number"
    t.string   "registration_agency"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "repartition_tables", force: true do |t|
    t.integer  "building_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "setups", force: true do |t|
    t.date     "balance_expenses"
    t.decimal  "iva"
    t.decimal  "istat"
    t.integer  "mav_expiration"
    t.integer  "invoice_generation"
    t.integer  "invoice_delivery"
    t.text     "unpaid_sentence"
    t.string   "erli_mav_email"
    t.boolean  "erli_mav_email_active"
    t.string   "erli_admin_email"
    t.integer  "building_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password"
    t.string   "salt"
    t.boolean  "admin"
    t.string   "pwcode"
    t.string   "activation_code"
    t.datetime "activation_code_set_at"
    t.string   "pw_code"
    t.string   "pw_code_set_at"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "codice_fiscale"
    t.string   "codice_salt"
    t.boolean  "secondary"
  end

end
