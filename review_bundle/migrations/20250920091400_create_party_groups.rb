class CreatePartyGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :party_groups do |t|
      t.string :name, null: false
      t.string :party_group_type_code, null: true

      t.timestamps
    end

    add_foreign_key :party_groups, :ref_party_group_types, column: :party_group_type_code, primary_key: :code
  end
end
