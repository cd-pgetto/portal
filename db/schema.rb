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

ActiveRecord::Schema[8.1].define(version: 2025_11_08_133839) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "availability", ["shared", "dedicated"]

  create_table "identity_providers", force: :cascade do |t|
    t.enum "availability", default: "shared", null: false, enum_type: "availability"
    t.string "client_id", null: false
    t.string "client_secret", null: false
    t.datetime "created_at", null: false
    t.string "icon_url", null: false
    t.string "name", null: false
    t.string "strategy", null: false
    t.datetime "updated_at", null: false
    t.index ["strategy", "client_id"], name: "index_identity_providers_on_strategy_and_client_id", unique: true
    t.index ["strategy"], name: "index_identity_providers_on_strategy", unique: true, where: "(availability = 'shared'::availability)"
  end

  create_table "organizations", force: :cascade do |t|
    t.boolean "allows_password_auth", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "subdomain", null: false
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_organizations_on_subdomain", unique: true
  end
end
