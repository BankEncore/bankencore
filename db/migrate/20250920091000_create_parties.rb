class CreateParties < ActiveRecord::Migration[8.0]
  def change
    create_table :parties do |t|
      t.string :public_id, null: false
      t.string :customer_number
      t.string :party_type, null: false, limit: 30

      t.binary :encrypted_tax_id
      t.binary :encrypted_tax_id_iv
      t.binary :encrypted_tax_id_salt
      t.string :tax_id_bidx
      t.string :tax_id_masked

      t.timestamps
    end

    add_index :parties, :public_id, unique: true
    add_index :parties, :customer_number, unique: true
    add_index :parties, :tax_id_bidx
  end
end
