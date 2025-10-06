# db/migrate/20251004214057_fix_party_links_indexes.rb
class FixPartyLinksIndexes < ActiveRecord::Migration[8.0]
  def up
    names = ActiveRecord::Base.connection.indexes(:party_links).map(&:name)

    remove_index :party_links, name: "idx_links_src_type_dates" if names.include?("idx_links_src_type_dates")
    remove_index :party_links, name: "idx_links_tgt_type_dates" if names.include?("idx_links_tgt_type_dates")

    add_index :party_links, [ :source_party_id, :party_link_type_code, :started_on, :ended_on ],
              name: "idx_links_src_type_dates"
    add_index :party_links, [ :target_party_id, :party_link_type_code, :started_on, :ended_on ],
              name: "idx_links_tgt_type_dates"
  end

  def down
    names = ActiveRecord::Base.connection.indexes(:party_links).map(&:name)

    remove_index :party_links, name: "idx_links_src_type_dates" if names.include?("idx_links_src_type_dates")
    remove_index :party_links, name: "idx_links_tgt_type_dates" if names.include?("idx_links_tgt_type_dates")

    add_index :party_links, [ :source_party_id, :party_link_type_code, :created_at, :updated_at ],
              name: "idx_links_src_type_dates"
    add_index :party_links, [ :target_party_id, :party_link_type_code, :created_at, :updated_at ],
              name: "idx_links_tgt_type_dates"
  end
end
