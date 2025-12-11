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

ActiveRecord::Schema[8.1].define(version: 2025_12_11_210006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "availability", ["shared", "dedicated"]
  create_enum "jaw_type", ["maxilla", "mandible"]
  create_enum "organization_role", ["owner", "admin", "member", "inactive"]
  create_enum "practice_role", ["owner", "admin", "member", "dentist", "hygienist", "assistant", "inactive"]
  create_enum "side", ["right", "left"]

  create_table "active_storage_attachments", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "credentials", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "identity_provider_id", null: false
    t.uuid "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_provider_id"], name: "index_credentials_on_identity_provider_id"
    t.index ["organization_id", "identity_provider_id"], name: "index_credentials_on_organization_id_and_identity_provider_id", unique: true
    t.index ["organization_id"], name: "index_credentials_on_organization_id"
  end

  create_table "dental_models", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "model_type", null: false
    t.string "name", null: false
    t.uuid "patient_id", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_dental_models_on_patient_id"
  end

  create_table "email_domains", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "domain_name", null: false
    t.uuid "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["domain_name"], name: "index_email_domains_on_domain_name", unique: true
    t.index ["organization_id"], name: "index_email_domains_on_organization_id"
  end

  create_table "identities", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "identity_provider_id", null: false
    t.string "provider_user_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["identity_provider_id"], name: "index_identities_on_identity_provider_id"
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "identity_providers", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
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

  create_table "jaws", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "dental_model_id", null: false
    t.enum "jaw_type", default: "maxilla", null: false, enum_type: "jaw_type"
    t.datetime "updated_at", null: false
    t.index ["dental_model_id", "jaw_type"], name: "index_jaws_on_dental_model_id_and_jaw_type", unique: true
    t.index ["dental_model_id"], name: "index_jaws_on_dental_model_id"
  end

  create_table "okta_identity_providers", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "identity_provider_id", null: false
    t.string "okta_domain", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_provider_id"], name: "index_okta_identity_providers_on_identity_provider_id"
  end

  create_table "organization_members", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "organization_id", null: false
    t.enum "role", default: "member", null: false, enum_type: "organization_role"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["organization_id"], name: "index_organization_members_on_organization_id"
    t.index ["user_id"], name: "index_organization_members_on_user_id"
  end

  create_table "organizations", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "email_domains_count", default: 0, null: false
    t.string "name", null: false
    t.boolean "password_auth_allowed", default: true, null: false
    t.integer "practices_count", default: 0, null: false
    t.string "subdomain", null: false
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_organizations_on_subdomain", unique: true
  end

  create_table "patients", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "chart_number", null: false
    t.datetime "created_at", null: false
    t.integer "dental_models_count", default: 0, null: false
    t.string "patient_number", null: false
    t.uuid "practice_id", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_id", "patient_number"], name: "index_patients_on_practice_id_and_patient_number", unique: true
    t.index ["practice_id"], name: "index_patients_on_practice_id"
  end

  create_table "practice_members", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "practice_id", null: false
    t.enum "role", default: "member", null: false, enum_type: "practice_role"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["practice_id"], name: "index_practice_members_on_practice_id"
    t.index ["user_id"], name: "index_practice_members_on_user_id"
  end

  create_table "practices", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "organization_id", null: false
    t.integer "patients_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_practices_on_organization_id"
  end

  create_table "sessions", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "teeth", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "jaw_id", null: false
    t.integer "number", null: false
    t.enum "side", null: false, enum_type: "side"
    t.datetime "updated_at", null: false
    t.index ["jaw_id"], name: "index_teeth_on_jaw_id"
  end

  create_table "users", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.integer "failed_login_count", default: 0, null: false
    t.string "first_name", null: false
    t.integer "identities_count", default: 0, null: false
    t.string "last_name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "credentials", "identity_providers"
  add_foreign_key "credentials", "organizations"
  add_foreign_key "dental_models", "patients"
  add_foreign_key "email_domains", "organizations"
  add_foreign_key "identities", "identity_providers"
  add_foreign_key "identities", "users"
  add_foreign_key "jaws", "dental_models"
  add_foreign_key "okta_identity_providers", "identity_providers"
  add_foreign_key "organization_members", "organizations"
  add_foreign_key "organization_members", "users"
  add_foreign_key "patients", "practices"
  add_foreign_key "practice_members", "practices"
  add_foreign_key "practice_members", "users"
  add_foreign_key "practices", "organizations"
  add_foreign_key "sessions", "users"
  add_foreign_key "teeth", "jaws"
end
