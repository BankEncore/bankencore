class BackfillPartyIdentifiers < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    say_with_time "Backfilling identifiers from parties.tax_id" do
      execute <<~SQL
        INSERT INTO party_identifiers
          (party_id, id_type_code, is_primary, value, value_bidx, value_masked, created_at, updated_at)
        SELECT
          p.id,
          CASE WHEN p.party_type = 'organization' THEN 'ein' ELSE 'ssn' END AS id_type_code,
          1 AS is_primary,
          p.tax_id        AS value,
          p.tax_id_bidx   AS value_bidx,
          p.tax_id_masked AS value_masked,
          NOW(), NOW()
        FROM parties p
        WHERE p.tax_id IS NOT NULL
          AND NOT EXISTS (
            SELECT 1 FROM party_identifiers pi
            WHERE pi.party_id = p.id
              AND pi.is_primary = 1
              AND pi.id_type_code IN ('ein','ssn')
          );
      SQL
    end
  end

  def down
    # Safe rollback: remove rows we inserted
    execute <<~SQL
      DELETE pi FROM party_identifiers pi
      WHERE pi.is_primary = 1
        AND pi.id_type_code IN ('ein','ssn')
        AND NOT EXISTS (
          SELECT 1 FROM party_identifiers pi2
          WHERE pi2.party_id = pi.party_id AND pi2.id < pi.id
        );
    SQL
  end
end
