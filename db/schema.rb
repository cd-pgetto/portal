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

ActiveRecord::Schema[8.1].define(version: 2025_11_12_231318) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "availability", ["shared", "dedicated"]

  create_table "credentials", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "identity_provider_id", null: false
    t.uuid "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_provider_id"], name: "index_credentials_on_identity_provider_id"
    t.index ["organization_id", "identity_provider_id"], name: "index_credentials_on_organization_id_and_identity_provider_id", unique: true
    t.index ["organization_id"], name: "index_credentials_on_organization_id"
  end

  create_table "email_domains", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "domain_name", null: false
    t.uuid "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["domain_name"], name: "index_email_domains_on_domain_name", unique: true
    t.index ["organization_id"], name: "index_email_domains_on_organization_id"
  end

  create_table "identity_providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.boolean "password_auth_allowed", default: true, null: false
    t.string "subdomain", null: false
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_organizations_on_subdomain", unique: true
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "original_first_name", null: false
    t.string "original_last_name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "credentials", "identity_providers"
  add_foreign_key "credentials", "organizations"
  add_foreign_key "email_domains", "organizations"
  add_foreign_key "sessions", "users"
end
