class CreatePartyGroupMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :party_group_memberships do |t|
      t.references :party, null: false, foreign_key: { to_table: :parties, on_delete: :cascade }
      t.references :group, null: false, foreign_key: { to_table: :party_groups, on_delete: :cascade }

      t.timestamps
    end

    add_index :party_group_memberships, [:party_id, :group_id], unique: true, name: "index_group_memberships_uniquely"
  end
end
