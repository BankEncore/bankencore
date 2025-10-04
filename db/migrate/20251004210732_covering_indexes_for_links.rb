class CoveringIndexesForLinks < ActiveRecord::Migration[8.0]
  def change
    cols = ActiveRecord::Base.connection.columns(:party_links).map(&:name).map!(&:to_sym)

    # Prefer real bounds. Fallback to timestamps. Finally, no dates.
    start_col = ([ :started_on, :starts_at, :effective_from, :created_at ] & cols).first
    end_col   = ([ :ended_on,   :ends_at,   :effective_to,   :updated_at ] & cols).first

    src_cols = [ :source_party_id, :party_link_type_code ]
    tgt_cols = [ :target_party_id, :party_link_type_code ]

    src_cols += [ start_col ] if start_col
    src_cols += [ end_col ]   if end_col
    tgt_cols += [ start_col ] if start_col
    tgt_cols += [ end_col ]   if end_col

    add_index :party_links, src_cols, name: "idx_links_src_type_dates" unless index_exists?(:party_links, src_cols, name: "idx_links_src_type_dates")
    add_index :party_links, tgt_cols, name: "idx_links_tgt_type_dates" unless index_exists?(:party_links, tgt_cols, name: "idx_links_tgt_type_dates")
  end
end
