# db/migrate/20250929_seed_ref_identifier_types.rb
class SeedRefIdentifierTypes < ActiveRecord::Migration[8.0]
  def up
    now = Time.current
    rows = [
      %w[ssn SSN 10 false false digits ssn],
      %w[itin ITIN 11 false false digits ssn],
      %w[ein EIN 12 false false digits ein],
      %w[foreign_tin Foreign\ TIN 13 false false digits last4],
      %w[passport Passport 20 true false uppercase_nospaces last4],
      %w[dl Driver\ License 21 true true uppercase_nospaces last4],
      %w[lei LEI 30 false false uppercase_nospaces last4]
    ]
    values = rows.map { |code, name, order, reqC, reqR, norm, mask|
      { code:, name:, sort_order: order, require_issuer_country: reqC, require_issuer_region: reqR,
        normalize_rule: norm, mask_rule: mask, created_at: now, updated_at: now }
    }
    execute "DELETE FROM ref_identifier_types"
    Ref::IdentifierType.insert_all!(values) if defined?(Ref::IdentifierType)
    # fallback when model not loaded during migration:
    values.each do |r|
      execute <<~SQL.squish
        INSERT INTO ref_identifier_types (code,name,sort_order,require_issuer_country,require_issuer_region,
          normalize_rule,mask_rule,created_at,updated_at)
        VALUES (#{ActiveRecord::Base.connection.quote(r[:code])},
                #{ActiveRecord::Base.connection.quote(r[:name])},
                #{r[:sort_order]}, #{r[:require_issuer_country]}, #{r[:require_issuer_region]},
                #{ActiveRecord::Base.connection.quote(r[:normalize_rule])},
                #{ActiveRecord::Base.connection.quote(r[:mask_rule])},
                NOW(), NOW())
        ON DUPLICATE KEY UPDATE name=VALUES(name), sort_order=VALUES(sort_order),
          require_issuer_country=VALUES(require_issuer_country),
          require_issuer_region=VALUES(require_issuer_region),
          normalize_rule=VALUES(normalize_rule), mask_rule=VALUES(mask_rule),
          updated_at=NOW()
      SQL
    end
  end
end
