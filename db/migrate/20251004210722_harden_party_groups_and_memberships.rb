# db/migrate/20251004130020_harden_party_groups_and_memberships.rb
class HardenPartyGroupsAndMemberships < ActiveRecord::Migration[8.0]
  def change
    add_column :party_groups, :party_group_type_code, :string unless column_exists?(:party_groups, :party_group_type_code)
    add_column :party_groups, :parent_group_id, :bigint unless column_exists?(:party_groups, :parent_group_id)

    add_foreign_key :party_groups, :ref_party_group_types,
      column: :party_group_type_code, primary_key: :code unless foreign_key_exists?(:party_groups, :ref_party_group_types, column: :party_group_type_code)

    add_foreign_key :party_groups, :party_groups,
      column: :parent_group_id unless foreign_key_exists?(:party_groups, :party_groups, column: :parent_group_id)

    add_index :party_groups, [ :party_group_type_code, :created_at ], name: "idx_groups_type_created" unless index_exists?(:party_groups, [ :party_group_type_code, :created_at ], name: "idx_groups_type_created")

    add_column :party_group_memberships, :role_code, :string unless column_exists?(:party_group_memberships, :role_code)
    add_index  :party_group_memberships, [ :group_id, :party_id, :started_on, :ended_on ], name: "idx_pgm_group_party_dates" unless index_exists?(:party_group_memberships, [ :group_id, :party_id, :started_on, :ended_on ], name: "idx_pgm_group_party_dates")
  end
end
