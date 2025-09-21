# db/migrate/20250921190000_fix_ref_regions_composite_fk.rb
class FixRefRegionsCompositeFk < ActiveRecord::Migration[8.0]
  def up
    # 0) Drop any existing FKs from party_addresses that might collide
    %w[
      fk_party_addresses_regions_country_region
      fk_pa_ref_regions_ccode_rcode
      party_addresses_ibfk_1
      party_addresses_ibfk_2
      party_addresses_region_code_fk
      party_addresses_country_code_fk
    ].each do |name|
      remove_foreign_key :party_addresses, name: name rescue nil
    end
    remove_foreign_key :party_addresses, column: :region_code  rescue nil
    remove_foreign_key :party_addresses, column: :country_code rescue nil

    # 1) Make ref_regions composite-unique (and drop old PK/unique on code)
    execute "ALTER TABLE ref_regions DROP PRIMARY KEY" rescue nil
    remove_index :ref_regions, column: :code, unique: true rescue nil
    add_index :ref_regions, [:country_code, :code],
              unique: true, name: "uniq_ref_regions_country_code" unless
      index_exists?(:ref_regions, [:country_code, :code], unique: true, name: "uniq_ref_regions_country_code")

    # 2) Ensure referencing composite index exists
    add_index :party_addresses, [:country_code, :region_code],
              name: "idx_party_addresses_country_region" unless
      index_exists?(:party_addresses, [:country_code, :region_code], name: "idx_party_addresses_country_region")

    # 3) Add composite FK with a fresh, schema-unique name
    add_foreign_key :party_addresses, :ref_regions,
      column:      [:country_code, :region_code],
      primary_key: [:country_code, :code],
      name:        "fk_pa_ref_regions_ccode_rcode",
      on_delete:   :restrict
  end

  def down
    remove_foreign_key :party_addresses, name: "fk_pa_ref_regions_ccode_rcode" rescue nil
    remove_index :party_addresses, name: "idx_party_addresses_country_region" rescue nil
    remove_index :ref_regions,     name: "uniq_ref_regions_country_code"    rescue nil
    add_index    :ref_regions, :code, unique: true unless index_exists?(:ref_regions, :code, unique: true)
    execute "ALTER TABLE ref_regions ADD PRIMARY KEY (code)" rescue nil
  end
end
