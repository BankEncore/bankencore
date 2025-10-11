class AddCitizenshipFieldsToPartyPeople < ActiveRecord::Migration[7.2]
  def change
    add_column :party_people, :citizenship, :integer, null: false, default: 0  # 0=domestic, 1=foreign
    add_column :party_people, :nationality_country_code, :string, limit: 2
    add_column :party_people, :residence_country_code,   :string, limit: 2, null: false, default: "US"

    add_index :party_people, :citizenship
    add_index :party_people, :nationality_country_code
    add_index :party_people, :residence_country_code

    add_foreign_key :party_people, :ref_countries, column: :nationality_country_code, primary_key: :code
    add_foreign_key :party_people, :ref_countries, column: :residence_country_code,   primary_key: :code

    # Guardrails
    add_check_constraint :party_people,
      "(citizenship = 0 AND (nationality_country_code IS NULL OR nationality_country_code = 'US')) OR (citizenship = 1 AND nationality_country_code IS NOT NULL AND nationality_country_code <> 'US')",
      name: "chk_people_citizenship_nationality"

    add_check_constraint :party_people,
      "residence_country_code IS NOT NULL",
      name: "chk_people_residence_present"
  end
end
