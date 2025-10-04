# db/migrate/20251004130010_extend_ref_party_group_types.rb
class ExtendRefPartyGroupTypes < ActiveRecord::Migration[8.0]
  def change
    add_column :ref_party_group_types, :allowed_party_types, :json, default: [], null: false unless column_exists?(:ref_party_group_types, :allowed_party_types)
    add_column :ref_party_group_types, :allowed_group_roles, :json, default: [], null: false unless column_exists?(:ref_party_group_types, :allowed_group_roles)
    add_column :ref_party_group_types, :hierarchical, :boolean, default: false, null: false unless column_exists?(:ref_party_group_types, :hierarchical)
  end
end
