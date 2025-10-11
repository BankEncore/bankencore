class CreateRefPartyLinkTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :ref_party_link_types, id: false, primary_key: :code do |t|
      t.string :code, null: false, primary_key: true
      t.string :name, null: false
      t.boolean :symmetric, null: false, default: false
      t.string :inverse_code

      t.timestamps
    end
    add_index :ref_party_link_types, :code, unique: true
    add_index :ref_party_link_types, :inverse_code
  end
end
