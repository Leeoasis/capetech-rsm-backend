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

ActiveRecord::Schema[8.1].define(version: 2026_02_08_110313) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "activity_logs", force: :cascade do |t|
    t.string "action_type"
    t.datetime "created_at", null: false
    t.text "description"
    t.jsonb "metadata"
    t.integer "repair_ticket_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["action_type"], name: "index_activity_logs_on_action_type"
    t.index ["created_at"], name: "index_activity_logs_on_created_at"
    t.index ["repair_ticket_id"], name: "index_activity_logs_on_repair_ticket_id"
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

  create_table "customers", force: :cascade do |t|
    t.boolean "active", default: true
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "email"
    t.string "first_name"
    t.string "id_number"
    t.string "last_name"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_customers_on_deleted_at"
    t.index ["email"], name: "index_customers_on_email"
    t.index ["phone"], name: "index_customers_on_phone"
  end

  create_table "devices", force: :cascade do |t|
    t.string "brand"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.datetime "deleted_at"
    t.integer "device_type"
    t.string "imei"
    t.string "model"
    t.text "notes"
    t.string "password_pin"
    t.string "serial_number"
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_devices_on_customer_id"
    t.index ["deleted_at"], name: "index_devices_on_deleted_at"
    t.index ["device_type"], name: "index_devices_on_device_type"
    t.index ["imei"], name: "index_devices_on_imei"
    t.index ["serial_number"], name: "index_devices_on_serial_number"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.text "notes"
    t.datetime "payment_date"
    t.integer "payment_method"
    t.integer "received_by_user_id"
    t.string "reference_number"
    t.bigint "repair_ticket_id", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_date"], name: "index_payments_on_payment_date"
    t.index ["payment_method"], name: "index_payments_on_payment_method"
    t.index ["repair_ticket_id"], name: "index_payments_on_repair_ticket_id"
  end

  create_table "repair_statuses", force: :cascade do |t|
    t.integer "changed_by_user_id"
    t.datetime "created_at", null: false
    t.text "notes"
    t.bigint "repair_ticket_id", null: false
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_repair_statuses_on_created_at"
    t.index ["repair_ticket_id"], name: "index_repair_statuses_on_repair_ticket_id"
  end

  create_table "repair_tickets", force: :cascade do |t|
    t.text "accessories_received"
    t.decimal "actual_cost", precision: 10, scale: 2
    t.integer "assigned_technician_id"
    t.datetime "collected_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.bigint "device_id", null: false
    t.decimal "estimated_cost", precision: 10, scale: 2
    t.text "fault_description"
    t.integer "priority"
    t.integer "status"
    t.string "ticket_number"
    t.datetime "updated_at", null: false
    t.index ["assigned_technician_id"], name: "index_repair_tickets_on_assigned_technician_id"
    t.index ["created_at"], name: "index_repair_tickets_on_created_at"
    t.index ["customer_id"], name: "index_repair_tickets_on_customer_id"
    t.index ["device_id"], name: "index_repair_tickets_on_device_id"
    t.index ["priority"], name: "index_repair_tickets_on_priority"
    t.index ["status"], name: "index_repair_tickets_on_status"
    t.index ["ticket_number"], name: "index_repair_tickets_on_ticket_number", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest"
    t.integer "role"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "activity_logs", "users"
  add_foreign_key "devices", "customers"
  add_foreign_key "payments", "repair_tickets"
  add_foreign_key "payments", "users", column: "received_by_user_id"
  add_foreign_key "repair_statuses", "repair_tickets"
  add_foreign_key "repair_statuses", "users", column: "changed_by_user_id"
  add_foreign_key "repair_tickets", "customers"
  add_foreign_key "repair_tickets", "devices"
  add_foreign_key "repair_tickets", "users", column: "assigned_technician_id"
end
