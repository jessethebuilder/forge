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

ActiveRecord::Schema.define(version: 2021_06_06_112617) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.boolean "active", default: true
    t.jsonb "data", default: {}
    t.string "sms"
    t.string "email"
    t.string "stripe_key"
    t.string "stripe_secret"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "credentials", force: :cascade do |t|
    t.string "token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "account_id"
    t.index ["account_id"], name: "index_credentials_on_account_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.jsonb "data", default: {}
    t.string "stripe_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "account_id"
    t.index ["account_id"], name: "index_customers_on_account_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "order"
    t.jsonb "data", default: {}
    t.boolean "active", default: true
    t.boolean "archived", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "account_id"
    t.bigint "menu_id"
    t.index ["account_id"], name: "index_groups_on_account_id"
    t.index ["menu_id"], name: "index_groups_on_menu_id"
  end

  create_table "menus", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.jsonb "data", default: {}
    t.boolean "active", default: true
    t.boolean "archived", default: false
    t.string "sms"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "account_id"
    t.index ["account_id"], name: "index_menus_on_account_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "amount"
    t.jsonb "data", default: {}
    t.string "note"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "order_id"
    t.bigint "product_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "order_notifications", force: :cascade do |t|
    t.text "message"
    t.string "message_type"
    t.bigint "order_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_order_notifications_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.jsonb "data", default: {}
    t.string "note"
    t.integer "tip", default: 0
    t.integer "tax", default: 0
    t.datetime "seen_at"
    t.datetime "delivered_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "account_id"
    t.bigint "menu_id"
    t.bigint "customer_id"
    t.index ["account_id"], name: "index_orders_on_account_id"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["menu_id"], name: "index_orders_on_menu_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "order"
    t.integer "price"
    t.jsonb "data", default: {}
    t.boolean "active", default: true
    t.boolean "archived", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "account_id"
    t.bigint "menu_id"
    t.bigint "group_id"
    t.index ["account_id"], name: "index_products_on_account_id"
    t.index ["group_id"], name: "index_products_on_group_id"
    t.index ["menu_id"], name: "index_products_on_menu_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "amount"
    t.string "stripe_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "order_id"
    t.index ["order_id"], name: "index_transactions_on_order_id"
  end

  add_foreign_key "credentials", "accounts"
  add_foreign_key "customers", "accounts"
  add_foreign_key "groups", "accounts"
  add_foreign_key "menus", "accounts"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "order_notifications", "orders"
  add_foreign_key "orders", "accounts"
  add_foreign_key "products", "accounts"
  add_foreign_key "transactions", "orders"
end
