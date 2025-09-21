class AddTaxIdBidxToParties < ActiveRecord::Migration[8.0]
  def up
    # 1) Add column if missing (no type filter to avoid false negatives)
    unless column_exists?(:parties, :tax_id_bidx)
      add_column :parties, :tax_id_bidx, :binary, limit: 32 # NOT NULL enforced below
    end

    # 2) Normalize type/limit and nullability
    normalize_tax_id_bidx!

    # 3) Ensure index exists (toggle unique: true if you want uniqueness)
    unless index_exists?(:parties, :tax_id_bidx, name: "index_parties_on_tax_id_bidx")
      add_index :parties, :tax_id_bidx, unique: true, name: "index_parties_on_tax_id_bidx"
    end
  end

  def down
    remove_index :parties, name: "index_parties_on_tax_id_bidx" if index_exists?(:parties, :tax_id_bidx, name: "index_parties_on_tax_id_bidx")
    remove_column :parties, :tax_id_bidx if column_exists?(:parties, :tax_id_bidx)
  end

  private

  def normalize_tax_id_bidx!
    col = connection.columns(:parties).find { |c| c.name == "tax_id_bidx" }

    # Correct type/limit if needed
    unless col.sql_type =~ /binary/i && col.limit == 32
      change_column :parties, :tax_id_bidx, :binary, limit: 32
    end

    # Enforce NOT NULL only if you truly require it (and after backfilling).
    # Uncomment after backfill:
    # change_column_null :parties, :tax_id_bidx, false
  end
end
