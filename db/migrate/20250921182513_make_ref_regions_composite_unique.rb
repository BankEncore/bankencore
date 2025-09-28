# db/migrate/20250921000000_make_ref_regions_composite_unique.rb
class MakeRefRegionsCompositeUnique < ActiveRecord::Migration[8.0]
  def up
    # 1) Drop old FK (region_code -> ref_regions.code)
    remove_foreign_key :party_addresses, column: :region_code rescue nil

    # 2) RefRegions: drop unique(code), add unique([country_code, code])
    if index_exists?(:ref_regions, :code, unique: true)
      remove_index :ref_regions, column: :code
    end
    add_index :ref_regions, [ :country_code, :code ], unique: true, name: "index_ref_regions_on_country_and_code"
    add_index :ref_regions, :country_code unless index_exists?(:ref_regions, :country_code)

    # 3) Add composite FK (party_addresses.[country_code,region_code] -> ref_regions.[country_code,code])
    add_foreign_key :party_addresses, :ref_regions,
      column: [ :country_code, :region_code ],
      primary_key: [ :country_code, :code ],
      name: "fk_party_addresses_regions_country_region",
      on_delete: :restrict
  end

  def down
    # Drop composite FK & index
    remove_foreign_key :party_addresses, name: "fk_party_addresses_regions_country_region" rescue nil
    remove_index :ref_regions, name: "index_ref_regions_on_country_and_code" if index_exists?(:ref_regions, name: "index_ref_regions_on_country_and_code")

    # Restore unique(code)
    add_index :ref_regions, :code, unique: true unless index_exists?(:ref_regions, :code, unique: true)

    # Restore simple FK (region_code -> code)
    add_foreign_key :party_addresses, :ref_regions,
      column: :region_code, primary_key: :code, on_delete: :restrict
  end
end
