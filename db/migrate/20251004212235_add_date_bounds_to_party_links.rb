# db/migrate/20251004221000_add_date_bounds_to_party_links.rb
class AddDateBoundsToPartyLinks < ActiveRecord::Migration[8.0]
  def up
    # started_on: required, default today
    add_column :party_links, :started_on, :date, null: false, default: -> { "CURRENT_DATE" } unless column_exists?(:party_links, :started_on)

    # ended_on: optional
    add_column :party_links, :ended_on, :date unless column_exists?(:party_links, :ended_on)

    # backfill started_on for preexisting rows (safety if default didn’t apply)
    execute "UPDATE party_links SET started_on = DATE(created_at) WHERE started_on IS NULL"
  end

  def down
    remove_index :party_links, name: "idx_links_src_type_dates" if index_exists?(:party_links, name: "idx_links_src_type_dates")
    remove_index :party_links, name: "idx_links_tgt_type_dates" if index_exists?(:party_links, name: "idx_links_tgt_type_dates")
    remove_column :party_links, :ended_on if column_exists?(:party_links, :ended_on)
    remove_column :party_links, :started_on if column_exists?(:party_links, :started_on)
  end
end
