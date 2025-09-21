class CreatePartySubprofiles < ActiveRecord::Migration[8.0]
  def change
    create_table :party_people, id: false do |t|
      t.references :party, null: false, primary_key: true, foreign_key: { on_delete: :cascade }
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.timestamps
    end

    create_table :party_organizations, id: false do |t|
      t.references :party, null: false, primary_key: true, foreign_key: { on_delete: :cascade }
      t.string :legal_name
      t.string :organization_type_code, null: false, limit: 32
      t.date :formation_date
      t.timestamps
    end

    add_foreign_key :party_organizations, :ref_organization_types, column: :organization_type_code, primary_key: :code
  end
end
