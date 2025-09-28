class CreatePartyContacts < ActiveRecord::Migration[8.0]
  def change
    # Emails
    create_table :party_emails do |t|
      t.references :party, null: false, foreign_key: { on_delete: :cascade }
      t.string :email_type_code, null: false, limit: 16

      t.binary :encrypted_email
      t.binary :encrypted_email_iv
      t.binary :encrypted_email_salt
      t.string :email_bidx, null: false
      t.string :email_masked
      t.string :domain

      t.boolean :is_primary, null: false, default: false
      t.timestamps
    end

    add_foreign_key :party_emails, :ref_email_types, column: :email_type_code, primary_key: :code
    add_index :party_emails, [ :party_id, :email_bidx ], unique: true

    # Phones
    create_table :party_phones do |t|
      t.references :party, null: false, foreign_key: { on_delete: :cascade }
      t.string :phone_type_code, null: false, limit: 16
      t.string :phone_e164, null: false, limit: 20
      t.string :phone_ext, limit: 10
      t.boolean :is_primary, null: false, default: false
      t.boolean :consent_sms, null: false, default: false
      t.timestamps
    end

    add_foreign_key :party_phones, :ref_phone_types, column: :phone_type_code, primary_key: :code
    add_index :party_phones, [ :party_id, :phone_e164, :phone_ext ], unique: true

    # Addresses
    create_table :party_addresses do |t|
      t.references :party, null: false, foreign_key: { on_delete: :cascade }
      t.string :address_type_code, null: false, limit: 32
      t.string :line1
      t.string :line2
      t.string :line3
      t.string :locality
      t.string :region_code, limit: 10
      t.string :postal_code
      t.string :country_code, limit: 2, null: false
      t.boolean :is_primary, null: false, default: false
      t.timestamps
    end

    add_foreign_key :party_addresses, :ref_address_types, column: :address_type_code, primary_key: :code
    add_foreign_key :party_addresses, :ref_countries, column: :country_code, primary_key: :code
    add_foreign_key :party_addresses, :ref_regions, column: :region_code, primary_key: :code
  end
end
