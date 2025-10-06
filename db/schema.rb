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

ActiveRecord::Schema[8.0].define(version: 2025_10_06_041838) do
  create_table "customer_number_counters", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "current_value", null: false
    t.integer "min_value", default: 1001, null: false
    t.integer "max_value", default: 9999999, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "parties", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "public_id", limit: 36, null: false
    t.string "customer_number", limit: 10
    t.string "party_type", limit: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_screened_at"
    t.integer "party_risk_score"
    t.integer "risk_band"
    t.index ["customer_number"], name: "index_parties_on_customer_number", unique: true
    t.index ["public_id"], name: "index_parties_on_public_id", unique: true
  end

  create_table "party_addresses", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "party_id", null: false
    t.string "address_type_code", limit: 32, null: false
    t.string "line1"
    t.string "line2"
    t.string "line3"
    t.string "locality"
    t.string "region_code", limit: 10
    t.string "postal_code"
    t.string "country_code", limit: 2, null: false
    t.boolean "is_primary", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_type_code"], name: "fk_rails_d3cf0b1de6"
    t.index ["country_code", "region_code"], name: "idx_party_addresses_country_region"
    t.index ["country_code"], name: "fk_rails_2ba3eb184e"
    t.index ["party_id"], name: "index_party_addresses_on_party_id"
    t.index ["region_code"], name: "fk_rails_4e90862570"
  end

  create_table "party_emails", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "party_id", null: false
    t.string "email_type_code", limit: 16, null: false
    t.binary "email_bidx", limit: 32, null: false
    t.string "email_masked"
    t.string "domain"
    t.boolean "is_primary", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", limit: 510
    t.index ["email_type_code"], name: "fk_rails_77478fab14"
    t.index ["party_id", "email_bidx"], name: "index_party_emails_on_party_and_bidx", unique: true
    t.index ["party_id", "email_bidx"], name: "index_party_emails_on_party_id_and_email_bidx", unique: true
    t.index ["party_id"], name: "index_party_emails_on_party_id"
  end

  create_table "party_group_memberships", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "party_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "started_on"
    t.date "ended_on"
    t.string "role_code"
    t.index ["group_id", "party_id", "started_on", "ended_on"], name: "idx_pgm_dedup_norole"
    t.index ["group_id", "party_id", "started_on", "ended_on"], name: "idx_pgm_group_party_dates"
    t.index ["group_id"], name: "index_party_group_memberships_on_group_id"
    t.index ["party_id", "group_id"], name: "index_group_memberships_uniquely", unique: true
    t.index ["party_id"], name: "index_party_group_memberships_on_party_id"
  end

  create_table "party_group_suggestions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "group_type_code", null: false
    t.string "name"
    t.text "members", size: :long, null: false, collation: "utf8mb4_bin"
    t.decimal "confidence_score", precision: 5, scale: 4, default: "0.0", null: false
    t.string "detected_by", null: false
    t.text "evidence", size: :long, collation: "utf8mb4_bin"
    t.boolean "reviewed_flag", default: false, null: false
    t.boolean "accepted_flag"
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accepted_flag"], name: "index_party_group_suggestions_on_accepted_flag"
    t.index ["group_type_code"], name: "index_party_group_suggestions_on_group_type_code"
    t.index ["reviewed_by_id"], name: "index_party_group_suggestions_on_reviewed_by_id"
    t.index ["reviewed_flag"], name: "index_party_group_suggestions_on_reviewed_flag"
    t.check_constraint "json_valid(`evidence`)", name: "chk_group_suggestions_evidence"
    t.check_constraint "json_valid(`members`)", name: "members"
  end

  create_table "party_groups", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "party_group_type_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_group_id"
    t.index ["parent_group_id"], name: "fk_rails_7505dd0a95"
    t.index ["party_group_type_code", "created_at"], name: "idx_groups_type_created"
    t.index ["party_group_type_code"], name: "fk_rails_c965026157"
  end

  create_table "party_identifiers", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "party_id", null: false
    t.string "id_type_code", null: false
    t.string "country_code"
    t.string "issuing_authority"
    t.date "issued_on"
    t.date "expires_on"
    t.string "status_code"
    t.boolean "is_primary", default: false, null: false
    t.string "value", null: false
    t.binary "value_bidx", limit: 32, null: false
    t.string "value_masked"
    t.datetime "verified_at"
    t.string "verification_ref"
    t.text "metadata", size: :long, collation: "utf8mb4_bin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "identifier_type_id"
    t.integer "value_len"
    t.string "value_last4", limit: 4
    t.index ["id_type_code", "value_bidx"], name: "idx_unique_identifier_value", unique: true
    t.index ["identifier_type_id", "value_bidx"], name: "idx_unique_identifier_type_value", unique: true
    t.index ["identifier_type_id"], name: "index_party_identifiers_on_identifier_type_id"
    t.index ["party_id", "id_type_code", "is_primary"], name: "idx_primary_identifier_by_party"
    t.index ["party_id", "id_type_code"], name: "idx_identifier_by_party_and_type"
    t.index ["party_id"], name: "index_party_identifiers_on_party_id"
    t.check_constraint "json_valid(`metadata`)", name: "metadata"
  end

  create_table "party_link_suggestions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "source_party_id", null: false
    t.bigint "target_party_id", null: false
    t.string "suggested_link_type_code", null: false
    t.decimal "confidence_score", precision: 5, scale: 4, default: "0.0", null: false
    t.string "detected_by", null: false
    t.text "evidence", size: :long, collation: "utf8mb4_bin"
    t.boolean "reviewed_flag", default: false, null: false
    t.boolean "accepted_flag"
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accepted_flag"], name: "index_party_link_suggestions_on_accepted_flag"
    t.index ["reviewed_by_id"], name: "index_party_link_suggestions_on_reviewed_by_id"
    t.index ["reviewed_flag"], name: "index_party_link_suggestions_on_reviewed_flag"
    t.index ["source_party_id", "target_party_id", "suggested_link_type_code"], name: "idx_pls_pair_type"
    t.index ["source_party_id"], name: "index_party_link_suggestions_on_source_party_id"
    t.index ["target_party_id"], name: "index_party_link_suggestions_on_target_party_id"
    t.check_constraint "json_valid(`evidence`)", name: "chk_link_suggestions_evidence"
  end

  create_table "party_links", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "source_party_id", null: false
    t.bigint "target_party_id", null: false
    t.string "party_link_type_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "started_on", default: -> { "curdate()" }, null: false
    t.date "ended_on"
    t.index ["party_link_type_code"], name: "fk_rails_6fccc90506"
    t.index ["source_party_id", "party_link_type_code", "started_on", "ended_on"], name: "idx_links_src_type_dates"
    t.index ["source_party_id", "target_party_id", "party_link_type_code"], name: "index_party_links_on_parties_and_type", unique: true
    t.index ["source_party_id"], name: "index_party_links_on_source_party_id"
    t.index ["target_party_id", "party_link_type_code", "started_on", "ended_on"], name: "idx_links_tgt_type_dates"
    t.index ["target_party_id"], name: "index_party_links_on_target_party_id"
  end

  create_table "party_organizations", primary_key: "party_id", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "legal_name"
    t.string "organization_type_code", limit: 32
    t.date "formation_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "operating_name"
    t.index ["organization_type_code"], name: "fk_rails_ad9f5a4e18"
    t.index ["party_id"], name: "index_party_organizations_on_party_id"
  end

  create_table "party_people", primary_key: "party_id", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "middle_name"
    t.string "name_suffix"
    t.string "courtesy_title"
    t.index ["party_id"], name: "index_party_people_on_party_id"
  end

  create_table "party_phones", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "party_id", null: false
    t.string "phone_type_code", limit: 16, null: false
    t.string "phone_e164", limit: 20, null: false
    t.string "phone_ext", limit: 10
    t.boolean "is_primary", default: false, null: false
    t.boolean "consent_sms", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["party_id", "phone_e164", "phone_ext"], name: "index_party_phones_on_party_id_and_phone_e164_and_phone_ext", unique: true
    t.index ["party_id"], name: "index_party_phones_on_party_id"
    t.index ["phone_type_code"], name: "fk_rails_21d3746b66"
  end

  create_table "party_screenings", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "party_id", null: false
    t.integer "vendor", default: 0, null: false
    t.integer "kind", null: false
    t.integer "status", default: 0, null: false
    t.string "query_name"
    t.date "query_dob"
    t.string "query_country", limit: 2
    t.string "query_identifier_type"
    t.string "query_identifier_last4"
    t.string "vendor_ref"
    t.decimal "vendor_score", precision: 6, scale: 2
    t.datetime "requested_at"
    t.datetime "completed_at"
    t.datetime "expires_at"
    t.text "vendor_payload", size: :long, null: false, collation: "utf8mb4_bin"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "normalized_score"
    t.integer "match_strength"
    t.text "risk_notes"
    t.index ["expires_at"], name: "index_party_screenings_on_expires_at"
    t.index ["party_id", "vendor", "kind", "status"], name: "idx_screenings_state"
    t.index ["party_id"], name: "index_party_screenings_on_party_id"
    t.check_constraint "json_valid(`vendor_payload`)", name: "vendor_payload"
  end

  create_table "ref_address_types", primary_key: "code", id: :string, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_ref_address_types_on_code", unique: true
  end

  create_table "ref_countries", primary_key: "code", id: { type: :string, limit: 2 }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_ref_countries_on_code", unique: true
  end

  create_table "ref_email_types", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_ref_email_types_on_code", unique: true
  end

  create_table "ref_identifier_types", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.integer "sort_order", default: 100, null: false
    t.boolean "require_issuer_country", default: false, null: false
    t.boolean "require_issuer_region", default: false, null: false
    t.string "normalize_rule"
    t.string "mask_rule"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "person_only", default: false, null: false
    t.boolean "organization_only", default: false, null: false
    t.index ["code"], name: "index_ref_identifier_types_on_code", unique: true
  end

  create_table "ref_organization_types", primary_key: "code", id: :string, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_ref_organization_types_on_code", unique: true
  end

  create_table "ref_party_group_types", primary_key: "code", id: :string, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "allowed_party_types", size: :long, default: "[]", null: false, collation: "utf8mb4_bin"
    t.text "allowed_group_roles", size: :long, default: "[]", null: false, collation: "utf8mb4_bin"
    t.boolean "hierarchical", default: false, null: false
    t.index ["code"], name: "index_ref_party_group_types_on_code", unique: true
    t.check_constraint "json_valid(`allowed_group_roles`)", name: "allowed_group_roles"
    t.check_constraint "json_valid(`allowed_party_types`)", name: "allowed_party_types"
  end

  create_table "ref_party_link_types", primary_key: "code", id: :string, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "symmetric", default: false, null: false
    t.string "inverse_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "allowed_from_party_types", size: :long, default: "[]", null: false, collation: "utf8mb4_bin"
    t.text "allowed_to_party_types", size: :long, default: "[]", null: false, collation: "utf8mb4_bin"
    t.string "default_from_role"
    t.string "default_to_role"
    t.index ["code"], name: "index_ref_party_link_types_on_code", unique: true
    t.index ["inverse_code"], name: "index_ref_party_link_types_on_inverse_code"
    t.check_constraint "json_valid(`allowed_from_party_types`)", name: "allowed_from_party_types"
    t.check_constraint "json_valid(`allowed_to_party_types`)", name: "allowed_to_party_types"
  end

  create_table "ref_phone_types", primary_key: "code", id: :string, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_ref_phone_types_on_code", unique: true
  end

  create_table "ref_regions", id: false, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "code", limit: 10, null: false
    t.string "name", null: false
    t.string "country_code", limit: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_code", "code"], name: "index_ref_regions_on_country_and_code", unique: true
    t.index ["country_code", "code"], name: "uniq_ref_regions_country_code", unique: true
    t.index ["country_code"], name: "fk_rails_27cb4ed1c4"
  end

  create_table "sessions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "party_addresses", "parties", on_delete: :cascade
  add_foreign_key "party_addresses", "ref_address_types", column: "address_type_code", primary_key: "code"
  add_foreign_key "party_addresses", "ref_regions", column: ["country_code", "region_code"], primary_key: ["country_code", "code"], name: "fk_pa_ref_regions_ccode_rcode"
  add_foreign_key "party_emails", "parties", on_delete: :cascade
  add_foreign_key "party_emails", "ref_email_types", column: "email_type_code", primary_key: "code"
  add_foreign_key "party_group_memberships", "parties", on_delete: :cascade
  add_foreign_key "party_group_memberships", "party_groups", column: "group_id", on_delete: :cascade
  add_foreign_key "party_group_suggestions", "users", column: "reviewed_by_id"
  add_foreign_key "party_groups", "party_groups", column: "parent_group_id"
  add_foreign_key "party_groups", "ref_party_group_types", column: "party_group_type_code", primary_key: "code"
  add_foreign_key "party_identifiers", "parties"
  add_foreign_key "party_identifiers", "ref_identifier_types", column: "identifier_type_id"
  add_foreign_key "party_link_suggestions", "parties", column: "source_party_id"
  add_foreign_key "party_link_suggestions", "parties", column: "target_party_id"
  add_foreign_key "party_link_suggestions", "users", column: "reviewed_by_id"
  add_foreign_key "party_links", "parties", column: "source_party_id", on_delete: :cascade
  add_foreign_key "party_links", "parties", column: "target_party_id", on_delete: :cascade
  add_foreign_key "party_links", "ref_party_link_types", column: "party_link_type_code", primary_key: "code"
  add_foreign_key "party_organizations", "parties", on_delete: :cascade
  add_foreign_key "party_organizations", "ref_organization_types", column: "organization_type_code", primary_key: "code"
  add_foreign_key "party_people", "parties", on_delete: :cascade
  add_foreign_key "party_phones", "parties", on_delete: :cascade
  add_foreign_key "party_phones", "ref_phone_types", column: "phone_type_code", primary_key: "code"
  add_foreign_key "party_screenings", "parties", on_delete: :cascade
  add_foreign_key "ref_regions", "ref_countries", column: "country_code", primary_key: "code"
  add_foreign_key "sessions", "users"
end
