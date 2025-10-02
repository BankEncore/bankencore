class AddIntervalToPartyGroupMemberships < ActiveRecord::Migration[7.2]
  def change
    # add columns only if missing
    add_column :party_group_memberships, :started_on, :date unless column_exists?(:party_group_memberships, :started_on)
    add_column :party_group_memberships, :ended_on,   :date unless column_exists?(:party_group_memberships, :ended_on)

    # build a dedup index that adapts if role_code doesn't exist
    cols = [ :group_id, :party_id ]
    cols << :role_code if column_exists?(:party_group_memberships, :role_code)
    cols += [ :started_on, :ended_on ]

    idx_name = column_exists?(:party_group_memberships, :role_code) ? "idx_pgm_dedup" : "idx_pgm_dedup_norole"
    add_index :party_group_memberships, cols, name: idx_name unless index_exists?(:party_group_memberships, cols, name: idx_name)
  end
end
