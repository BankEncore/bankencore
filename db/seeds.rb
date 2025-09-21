require 'countries'

puts "🌱 Seeding started at #{Time.current}"

timestamp = Time.current

SEED_CONFIG = {
  RefEmailType => [
    { code: "personal", name: "Personal" },
    { code: "work",     name: "Work" },
    { code: "billing",  name: "Billing" },
    { code: "other",    name: "Other" }
  ],
  RefPhoneType => [
    { code: "mobile", name: "Mobile" },
    { code: "home",   name: "Home" },
    { code: "work",   name: "Work" },
    { code: "fax",    name: "Fax" },
    { code: "other",  name: "Other" }
  ],
  RefAddressType => [
    { code: "residential",       name: "Residential" },
    { code: "mailing",           name: "Mailing" },
    { code: "business",          name: "Business" },
    { code: "registered_agent",  name: "Registered Agent" },
    { code: "former",            name: "Former" }
  ],
  RefOrganizationType => [
    { code: "sole_proprietor", name: "Sole Proprietor" },
    { code: "corp",            name: "Corporation" },
    { code: "s_corp",          name: "S Corporation" },
    { code: "llc",             name: "LLC" },
    { code: "partnership",     name: "Partnership" },
    { code: "nonprofit",       name: "Non-Profit" },
    { code: "government",      name: "Government" }
  ],
  RefPartyLinkType => [
    { code: "spouse_of",    name: "Spouse Of",    symmetric: true },
    { code: "parent_of",    name: "Parent Of",    inverse_code: "child_of" },
    { code: "child_of",     name: "Child Of",     inverse_code: "parent_of" },
    { code: "parent_org_of",   name: "Parent Of",      inverse_code: "subsidiary_of" },
    { code: "subsidiary_of",   name: "Subsidiary Of",  inverse_code: "parent_org_of" },
    { code: "affiliate_of",    name: "Affiliate Of",   symmetric: true },
    { code: "director_of",     name: "Director Of",    inverse_code: "organization_for_director" },
    { code: "organization_for_director", name: "Organization for Director", inverse_code: "director_of" }
  ],
  RefPartyGroupType => [
    { code: "household",   name: "Household" },
    { code: "affiliation", name: "Affiliation" },
    { code: "committee",   name: "Committee" }
  ]
}

# 🌐 Countries
puts "🌐 Seeding RefCountries..."
ISO3166::Country.all.each do |country|
  name = country.translations["en"] || country["name"]
  next unless country.alpha2 && name

  record = RefCountry.find_or_initialize_by(code: country.alpha2)
  record.name = name
  record.updated_at = timestamp
  record.created_at ||= timestamp
  record.save!
end

# 🌍 Regions
puts "🌍 Seeding RefRegions..."
ISO3166::Country.all.each do |country|
  next unless country.alpha2 && country.subdivisions.present?

  country.subdivisions.each do |region_code, data|
    RefRegion.find_or_initialize_by(code: region_code[0,10]).tap do |region|
      region.country_code = country.alpha2
      region.name = data["name"][0,255]
      region.updated_at = timestamp
      region.created_at ||= timestamp
      region.save!
    end
  end
end


# 🔁 Seed remaining static reference tables
SEED_CONFIG.each do |model, records|
  puts "🔹 Seeding #{model.name.pluralize}..."
  records.each do |attrs|
    record = model.find_or_initialize_by(code: attrs[:code])
    record.assign_attributes(attrs)
    record.updated_at = timestamp
    record.created_at ||= timestamp
    record.save!
  end
end

puts "✅ Seeding complete at #{Time.current}"
