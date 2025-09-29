# db/migrate/XXXXXXXXXXXXXX_drop_legacy_tax_id_from_parties.rb
class DropLegacyTaxIdFromParties < ActiveRecord::Migration[7.1]
  def up
    # backfill already done to party_identifiers
    remove_column :parties, :tax_id_masked, :string      if column_exists?(:parties, :tax_id_masked)
    remove_column :parties, :tax_id_bidx,   :binary      if column_exists?(:parties, :tax_id_bidx)
    remove_column :parties, :tax_id,        :string      if column_exists?(:parties, :tax_id)
  end

  def down
    add_column :parties, :tax_id,        :string unless column_exists?(:parties, :tax_id)
    add_column :parties, :tax_id_bidx,   :binary, limit: 32 unless column_exists?(:parties, :tax_id_bidx)
    add_column :parties, :tax_id_masked, :string unless column_exists?(:parties, :tax_id_masked)

    add_index  :parties, :tax_id_bidx, unique: true, name: "idx_parties_tax_id_bidx" unless index_exists?(:parties, :tax_id_bidx, name: "idx_parties_tax_id_bidx")
  end
end
