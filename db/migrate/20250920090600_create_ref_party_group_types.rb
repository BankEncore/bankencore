class CreateRefPartyGroupTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :ref_party_group_types, id: false, primary_key: :code do |t|
      t.string :code, null: false, primary_key: true
      t.string :name, null: false

      t.timestamps
    end
    add_index :ref_party_group_types, :code, unique: true
  end
end
