class SwitchPartiesTaxIdToBuiltinEncryption < ActiveRecord::Migration[8.0]
  def up
    # Add single column that will store the encrypted payload (JSON/Base64).
    # Use 510 to be generous (Rails guide recommends larger than 255).
    add_column :parties, :tax_id, :string, limit: 510

    # If you had data in old columns and can decrypt it, backfill here.
    # (Skipping because previous setup stored only encrypted pieces.)

    # Drop legacy columns from pre-built-in setups
    remove_column :parties, :encrypted_tax_id, :binary, if_exists: true
    remove_column :parties, :encrypted_tax_id_iv, :binary, if_exists: true
    remove_column :parties, :encrypted_tax_id_salt, :binary, if_exists: true

    # Optional: keep these if you still want masked display or a separate bidx.
    remove_column :parties, :tax_id_bidx, :string, if_exists: true
    # keep :tax_id_masked if you use it for UI
  end

  def down
    add_column :parties, :encrypted_tax_id, :binary
    add_column :parties, :encrypted_tax_id_iv, :binary
    add_column :parties, :encrypted_tax_id_salt, :binary
    add_column :parties, :tax_id_bidx, :string

    remove_column :parties, :tax_id, :string
  end
end
