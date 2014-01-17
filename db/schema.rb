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

ActiveRecord::Schema.define(version: 20140116163112) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cluster_datapoints", force: true do |t|
    t.integer  "cluster_id"
    t.integer  "datapoint_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clusters", force: true do |t|
    t.integer  "solution_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "generated_cluster_id"
  end

  add_index "clusters", ["solution_id"], name: "index_clusters_on_solution_id", using: :btree

  create_table "control_solutions", force: true do |t|
    t.integer  "run_id"
    t.float    "connectivity"
    t.float    "deviation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "datapoints", force: true do |t|
    t.integer  "dataset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sequence_id"
  end

  add_index "datapoints", ["dataset_id"], name: "index_datapoints_on_dataset_id", using: :btree

  create_table "datasets", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "columns"
    t.integer  "rows"
  end

  create_table "datavalues", force: true do |t|
    t.float    "value"
    t.integer  "datapoint_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "datavalues", ["datapoint_id"], name: "index_datavalues_on_datapoint_id", using: :btree

  create_table "evidence_accumulation_solutions", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "run_id"
  end

  create_table "runs", force: true do |t|
    t.float    "runtime"
    t.integer  "dataset_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "completed"
  end

  create_table "solutions", force: true do |t|
    t.integer  "run_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "generated_solution_id"
    t.float    "connectivity"
    t.float    "deviation"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
