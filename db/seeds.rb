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

# ---------- static reference tables (string class names) ----------
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
    { code: "residential",       name: "Residential" },
    { code: "mailing",           name: "Mailing" },
    { code: "business",          name: "Business" },
    { code: "registered_agent",  name: "Registered Agent" },
    { code: "former",            name: "Former" }
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
    { code: "spouse_of",    name: "Spouse Of",    symmetric: true },
    { code: "parent_of",    name: "Parent Of",    inverse_code: "child_of" },
    { code: "child_of",     name: "Child Of",     inverse_code: "parent_of" },
    { code: "parent_org_of",   name: "Parent Of",      inverse_code: "subsidiary_of" },
    { code: "subsidiary_of",   name: "Subsidiary Of",  inverse_code: "parent_org_of" },
    { code: "affiliate_of",    name: "Affiliate Of",   symmetric: true },
    { code: "director_of",     name: "Director Of",    inverse_code: "organization_for_director" },
    { code: "organization_for_director", name: "Organization for Director", inverse_code: "director_of" }
  ],
  "Ref::PartyGroupType" => [
    { code: "household",   name: "Household" },
    { code: "affiliation", name: "Affiliation" },
    { code: "committee",   name: "Committee" }
  ],

  # Optional refs (will be skipped if models/tables are absent)
  "Ref::IdentifierType" => [
    { code: "ssn",      name: "SSN",      person_only: true },
    { code: "ein",      name: "EIN",      organization_only: true },
    { code: "tin",      name: "Tax ID" },
    { code: "passport", name: "Passport", person_only: true },
    { code: "dl",       name: "Driver License", person_only: true }
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
  u.password = "ChangeMe123!"
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
