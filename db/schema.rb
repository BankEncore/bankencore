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

ActiveRecord::Schema[8.0].define(version: 2025_09_22_013132) do
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
    t.string "tax_id_masked"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tax_id", limit: 510
    t.binary "tax_id_bidx", limit: 32
    t.index ["customer_number"], name: "index_parties_on_customer_number", unique: true
    t.index ["public_id"], name: "index_parties_on_public_id", unique: true
    t.index ["tax_id_bidx"], name: "index_parties_on_tax_id_bidx", unique: true
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
    t.index ["group_id"], name: "index_party_group_memberships_on_group_id"
    t.index ["party_id", "group_id"], name: "index_group_memberships_uniquely", unique: true
    t.index ["party_id"], name: "index_party_group_memberships_on_party_id"
  end

  create_table "party_groups", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "party_group_type_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["party_group_type_code"], name: "fk_rails_c965026157"
  end

  create_table "party_links", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "source_party_id", null: false
    t.bigint "target_party_id", null: false
    t.string "party_link_type_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["party_link_type_code"], name: "fk_rails_6fccc90506"
    t.index ["source_party_id", "target_party_id", "party_link_type_code"], name: "index_party_links_on_parties_and_type", unique: true
    t.index ["source_party_id"], name: "index_party_links_on_source_party_id"
    t.index ["target_party_id"], name: "index_party_links_on_target_party_id"
  end

  create_table "party_organizations", primary_key: "party_id", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "legal_name"
    t.string "organization_type_code", limit: 32
    t.date "formation_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["code"], name: "index_ref_party_group_types_on_code", unique: true
  end

  create_table "ref_party_link_types", primary_key: "code", id: :string, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "symmetric", default: false, null: false
    t.string "inverse_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_ref_party_link_types_on_code", unique: true
    t.index ["inverse_code"], name: "index_ref_party_link_types_on_inverse_code"
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

  add_foreign_key "party_addresses", "parties", on_delete: :cascade
  add_foreign_key "party_addresses", "ref_address_types", column: "address_type_code", primary_key: "code"
  add_foreign_key "party_addresses", "ref_regions", column: ["country_code", "region_code"], primary_key: ["country_code", "code"], name: "fk_pa_ref_regions_ccode_rcode"
  add_foreign_key "party_emails", "parties", on_delete: :cascade
  add_foreign_key "party_emails", "ref_email_types", column: "email_type_code", primary_key: "code"
  add_foreign_key "party_group_memberships", "parties", on_delete: :cascade
  add_foreign_key "party_group_memberships", "party_groups", column: "group_id", on_delete: :cascade
  add_foreign_key "party_groups", "ref_party_group_types", column: "party_group_type_code", primary_key: "code"
  add_foreign_key "party_links", "parties", column: "source_party_id", on_delete: :cascade
  add_foreign_key "party_links", "parties", column: "target_party_id", on_delete: :cascade
  add_foreign_key "party_links", "ref_party_link_types", column: "party_link_type_code", primary_key: "code"
  add_foreign_key "party_organizations", "parties", on_delete: :cascade
  add_foreign_key "party_organizations", "ref_organization_types", column: "organization_type_code", primary_key: "code"
  add_foreign_key "party_people", "parties", on_delete: :cascade
  add_foreign_key "party_phones", "parties", on_delete: :cascade
  add_foreign_key "party_phones", "ref_phone_types", column: "phone_type_code", primary_key: "code"
  add_foreign_key "ref_regions", "ref_countries", column: "country_code", primary_key: "code"
end
