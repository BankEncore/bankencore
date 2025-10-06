# db/migrate/20251004130000_extend_ref_party_link_types.rb
class ExtendRefPartyLinkTypes < ActiveRecord::Migration[8.0]
  def change
    add_column :ref_party_link_types, :inverse_code, :string unless column_exists?(:ref_party_link_types, :inverse_code)
    add_column :ref_party_link_types, :symmetric, :boolean, default: false, null: false unless column_exists?(:ref_party_link_types, :symmetric)
    add_column :ref_party_link_types, :allowed_from_party_types, :json, default: [], null: false unless column_exists?(:ref_party_link_types, :allowed_from_party_types)
    add_column :ref_party_link_types, :allowed_to_party_types,   :json, default: [], null: false unless column_exists?(:ref_party_link_types, :allowed_to_party_types)
    add_column :ref_party_link_types, :default_from_role, :string unless column_exists?(:ref_party_link_types, :default_from_role)
    add_column :ref_party_link_types, :default_to_role,   :string unless column_exists?(:ref_party_link_types, :default_to_role)
    add_index  :ref_party_link_types, :inverse_code unless index_exists?(:ref_party_link_types, :inverse_code)
  end
end
