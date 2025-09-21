# db/seeds/countries_and_regions.rb
require 'countries'

puts "🌍 Seeding Countries & Regions (ISO 3166)..."

timestamp = Time.current
country_count = 0
region_count = 0

ISO3166::Country.all.each do |country|
  next unless country.alpha2 && country.name

  RefCountry.upsert(
    {
      code: country.alpha2,
      name: country.name,
      created_at: timestamp,
      updated_at: timestamp
    },
    unique_by: :primary_key
  )
  country_count += 1

  if country.subdivisions.present?
    country.subdivisions.each do |sub_code, sub_data|
      RefRegion.upsert(
        {
          code: sub_code[0,10],  # Truncate to 10 chars max
          name: sub_data['name'][0,255], # Truncate just in case
          country_code: country.alpha2,
          created_at: timestamp,
          updated_at: timestamp
        },
        unique_by: :primary_key
      )
      region_count += 1
    end
  end
end

puts "✅ Seeded #{country_count} countries and #{region_count} regions."
