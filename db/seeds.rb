# db/seeds.rb
require "countries"
Rails.application.eager_load!
return if Rails.env.test? || ENV["SKIP_SEEDS"] == "1"

puts "🌱 Seeding started at #{Time.current}"
timestamp = Time.current

# ---- helper ----
def seed_records_by!(klass_name, rows, by: :code, timestamp:)
  model = klass_name.safe_constantize
  unless model
    puts "⚠️  Skipping #{klass_name} (model missing)"
    return
  end
  puts "🔹 Seeding #{klass_name.to_s.demodulize.pluralize}..."
  rows.each do |attrs|
    rec = model.find_or_initialize_by(by => attrs[by])
    rec.assign_attributes(attrs)
    rec.updated_at = timestamp
    rec.created_at ||= timestamp
    rec.save!
  end
end

# ---------- static reference tables ----------
SEED_CONFIG = {
  "Ref::EmailType" => [
    { code: "personal", name: "Personal" },
    { code: "work",     name: "Work" },
    { code: "billing",  name: "Billing" },
    { code: "other",    name: "Other" }
  ],

  "Ref::PhoneType" => [
    { code: "mobile", name: "Mobile" },
    { code: "home",   name: "Home" },
    { code: "work",   name: "Work" },
    { code: "fax",    name: "Fax" },
    { code: "other",  name: "Other" }
  ],

  "Ref::AddressType" => [
    { code: "residential",      name: "Residential" },
    { code: "mailing",          name: "Mailing" },
    { code: "business",         name: "Business" },
    { code: "registered_agent", name: "Registered Agent" },
    { code: "former",           name: "Former" }
  ],

  "Ref::OrganizationType" => [
    { code: "sole_proprietor", name: "Sole Proprietor" },
    { code: "corp",            name: "Corporation" },
    { code: "s_corp",          name: "S Corporation" },
    { code: "llc",             name: "LLC" },
    { code: "partnership",     name: "Partnership" },
    { code: "nonprofit",       name: "Non-Profit" },
    { code: "government",      name: "Government" }
  ],

  "Ref::PartyLinkType" => [
    # symmetric
    { code: "spouse_of",         name: "Spouse Of",            symmetric: true },
    { code: "partner",           name: "Domestic Partner Of",  symmetric: true },
    { code: "affiliate_of",      name: "Affiliate Of",         symmetric: true },
    { code: "co_borrower_of",    name: "Co-Borrower Of",       symmetric: true },
    { code: "same_household_as", name: "In Same Household As", symmetric: true },
    { code: "related_party_of",  name: "Related Party Of",     symmetric: true },

    # directed pairs
    { code: "parent_of",                 name: "Parent Of",                    inverse_code: "child_of" },
    { code: "child_of",                  name: "Child Of",                     inverse_code: "parent_of" },
    { code: "guardian_of",               name: "Guardian Of",                  inverse_code: "ward_of" },
    { code: "ward_of",                   name: "Ward Of",                      inverse_code: "guardian_of" },
    { code: "custodian_of",              name: "Custodian Of",                 inverse_code: "has_custodian" },
    { code: "has_custodian",             name: "Has Custodian",                inverse_code: "custodian_of" },
    { code: "attorney_in_fact_for",      name: "Attorney-in-Fact For",         inverse_code: "has_attorney_in_fact" },
    { code: "has_attorney_in_fact",      name: "Has Attorney-in-Fact",         inverse_code: "attorney_in_fact_for" },
    { code: "representative_payee_for",  name: "Representative Payee For",     inverse_code: "has_representative_payee" },
    { code: "has_representative_payee",  name: "Has Representative Payee",     inverse_code: "representative_payee_for" },
    { code: "employer_of",               name: "Employer Of",                  inverse_code: "employee_of" },
    { code: "employee_of",               name: "Employee Of",                  inverse_code: "employer_of" },
    { code: "contractor_of",             name: "Contractor Of",                inverse_code: "client_of" },
    { code: "client_of",                 name: "Client Of",                    inverse_code: "contractor_of" },
    { code: "advisor_of",                name: "Advisor Of",                   inverse_code: "advised_by" },
    { code: "advised_by",                name: "Advised By",                   inverse_code: "advisor_of" },
    { code: "accountant_for",            name: "Accountant For",               inverse_code: "has_accountant" },
    { code: "has_accountant",            name: "Has Accountant",               inverse_code: "accountant_for" },
    { code: "attorney_for",              name: "Attorney For",                 inverse_code: "has_attorney" },
    { code: "has_attorney",              name: "Has Attorney",                 inverse_code: "attorney_for" },
    { code: "vendor_of",                 name: "Vendor Of",                    inverse_code: "customer_of" },
    { code: "customer_of",               name: "Customer Of",                  inverse_code: "vendor_of" },
    { code: "owner_of",                  name: "Owner Of",                     inverse_code: "owned_by" },
    { code: "owned_by",                  name: "Owned By",                     inverse_code: "owner_of" },
    { code: "beneficial_owner_of",       name: "Beneficial Owner Of",          inverse_code: "has_beneficial_owner" },
    { code: "has_beneficial_owner",      name: "Has Beneficial Owner",         inverse_code: "beneficial_owner_of" },
    { code: "shareholder_of",            name: "Shareholder Of",               inverse_code: "has_shareholder" },
    { code: "has_shareholder",           name: "Has Shareholder",              inverse_code: "shareholder_of" },
    { code: "member_of_llc",             name: "Member Of LLC",                inverse_code: "has_member" },
    { code: "has_member",                name: "Has LLC Member",               inverse_code: "member_of_llc" },
    { code: "manager_of_llc",            name: "Manager Of LLC",               inverse_code: "has_manager" },
    { code: "has_manager",               name: "Has LLC Manager",              inverse_code: "manager_of_llc" },
    { code: "officer_of",                name: "Officer Of",                   inverse_code: "has_officer" },
    { code: "has_officer",               name: "Has Officer",                  inverse_code: "officer_of" },
    { code: "director_of",               name: "Director Of",                  inverse_code: "organization_for_director" },
    { code: "organization_for_director", name: "Organization for Director",    inverse_code: "director_of" },
    { code: "control_person_of",         name: "Control Person Of",            inverse_code: "has_control_person" },
    { code: "has_control_person",        name: "Has Control Person",           inverse_code: "control_person_of" },
    { code: "parent_org_of",             name: "Parent Of",                    inverse_code: "subsidiary_of" },
    { code: "subsidiary_of",             name: "Subsidiary Of",                inverse_code: "parent_org_of" },
    { code: "franchisor_of",             name: "Franchisor Of",                inverse_code: "franchisee_of" },
    { code: "franchisee_of",             name: "Franchisee Of",                inverse_code: "franchisor_of" },
    { code: "guarantor_of",              name: "Guarantor Of",                 inverse_code: "has_guarantor" },
    { code: "has_guarantor",             name: "Has Guarantor",                inverse_code: "guarantor_of" },
    { code: "co_signer_of",              name: "Co-Signer Of",                 inverse_code: "has_co_signer" },
    { code: "has_co_signer",             name: "Has Co-Signer",                inverse_code: "co_signer_of" },
    { code: "pledgor_of",                name: "Pledgor Of",                   inverse_code: "has_pledgor" },
    { code: "has_pledgor",               name: "Has Pledgor",                  inverse_code: "pledgor_of" },
    { code: "trustee_of",                name: "Trustee Of",                   inverse_code: "has_trustee" },
    { code: "has_trustee",               name: "Has Trustee",                  inverse_code: "trustee_of" },
    { code: "settlor_of",                name: "Settlor Of",                   inverse_code: "has_settlor" },
    { code: "has_settlor",               name: "Has Settlor",                  inverse_code: "settlor_of" },
    { code: "protector_of",              name: "Protector Of",                 inverse_code: "has_protector" },
    { code: "has_protector",             name: "Has Protector",                inverse_code: "protector_of" },
    { code: "beneficiary_of",            name: "Beneficiary Of",               inverse_code: "has_beneficiary" },
    { code: "has_beneficiary",           name: "Has Beneficiary",              inverse_code: "beneficiary_of" },
    { code: "executor_of",               name: "Executor Of",                  inverse_code: "has_executor" },
    { code: "has_executor",              name: "Has Executor",                 inverse_code: "executor_of" },
    { code: "personal_representative_of", name: "Personal Representative Of",  inverse_code: "has_personal_representative" },
    { code: "has_personal_representative", name: "Has Personal Representative", inverse_code: "personal_representative_of" },
    { code: "agent_of",                  name: "Agent Of",                     inverse_code: "principal_of" },
    { code: "principal_of",              name: "Principal Of",                 inverse_code: "agent_of" },
    { code: "reference_for",             name: "Reference For",                inverse_code: "referred_by" },
    { code: "referred_by",               name: "Referred By",                  inverse_code: "reference_for" },
    { code: "introduced",                name: "Introduced",                   inverse_code: "introduced_by" },
    { code: "introduced_by",             name: "Introduced By",                inverse_code: "introduced" }
  ],

  "Ref::PartyGroupType" => [
    { code: "household",         name: "Household" },
    { code: "corporate_family",  name: "Corporate Family" },
    { code: "trust",             name: "Trust" },
    { code: "estate",            name: "Estate" },
    { code: "org_unit",          name: "Organization Unit" },
    { code: "association",       name: "Association or Club" },
    { code: "customer_segment",  name: "Customer Segment" },
    { code: "affiliation",       name: "Affiliation" },
    { code: "committee",         name: "Committee" }
  ],

  # Optional refs (will be skipped if models/tables are absent)
  "Ref::IdentifierType" => [
    { code: "ssn",         name: "SSN",            person_only: true,  mask_rule: "ssn"  },
    { code: "ein",         name: "EIN",            organization_only: true, mask_rule: "ein" },
    { code: "itin",        name: "ITIN",           person_only: true,  mask_rule: "ssn"  },
    { code: "foreign_tin", name: "Foreign TIN",    mask_rule: "ssn"  },
    { code: "tin",         name: "Tax ID",         mask_rule: "ssn"  },
    { code: "passport",    name: "Passport",       person_only: true,  require_issuer_country: true, mask_rule: "last4" },
    { code: "dl",          name: "Driver License", person_only: true,  require_issuer_country: true, mask_rule: "last4" },
    { code: "lei",         name: "LEI",                                mask_rule: "last4" }
],

  "Ref::NameType" => [
    { code: "legal",  name: "Legal Name" },
    { code: "alias",  name: "Alias / AKA" },
    { code: "former", name: "Former Name" },
    { code: "dba",    name: "Doing Business As" }
  ],

  "Ref::TaxRegime" => [
    { code: "us_federal", name: "United States Federal" },
    { code: "us_state",   name: "United States State" },
    { code: "ca_federal", name: "Canada Federal" }
  ],

  "Ref::TaxClassification" => [
    { code: "individual",         name: "Individual" },
    { code: "disregarded_entity", name: "Disregarded Entity" },
    { code: "c_corp",             name: "C Corporation" },
    { code: "s_corp",             name: "S Corporation" },
    { code: "partnership",        name: "Partnership" },
    { code: "trust_estate",       name: "Trust/Estate" },
    { code: "nonprofit",          name: "Nonprofit Organization" },
    { code: "government",         name: "Government" }
  ]
}

User.find_or_create_by!(email_address: "admin@example.com") do |u|
  u.password   = "ChangeMe123!"
  u.first_name = "Admin"
  u.last_name  = "User"
end

SEED_CONFIG.each do |klass_name, rows|
  seed_records_by!(klass_name, rows, by: :code, timestamp: timestamp)
end

# ---------- Countries ----------
puts "🌐 Seeding RefCountries..."
if (country_model = "Ref::Country".safe_constantize)
  ISO3166::Country.all.each do |c|
    name = c.translations["en"] || c["name"]
    next unless c.alpha2 && name
    rec = country_model.find_or_initialize_by(code: c.alpha2)
    rec.name = name
    rec.updated_at = timestamp
    rec.created_at ||= timestamp
    rec.save!
  end
else
  puts "⚠️  Skipping Ref::Country (model missing)"
end

# ---------- Regions ----------
puts "🌍 Seeding RefRegions..."
if (region_model = "Ref::Region".safe_constantize)
  ISO3166::Country.all.each do |c|
    next unless c.alpha2 && c.subdivisions.present?
    c.subdivisions.each do |code, data|
      rec = region_model.find_or_initialize_by(code: code.to_s[0, 10], country_code: c.alpha2)
      rec.name = data["name"].to_s[0, 255]
      rec.updated_at = timestamp
      rec.created_at ||= timestamp
      rec.save!
    end
  end
else
  puts "⚠️  Skipping Ref::Region (model missing)"
end

puts "✅ Seeding complete at #{Time.current}"
