# db/migrate/20251006000000_fix_duplicate_evidence_checks.rb
class FixDuplicateEvidenceCheck < ActiveRecord::Migration[7.2]
  def up
    return unless mysql_or_mariadb?

    fix_check(:party_group_suggestions,  "chk_group_suggestions_evidence")
    fix_check(:party_link_suggestions,   "chk_link_suggestions_evidence")
  end

  def down
    return unless mysql_or_mariadb?

    drop_check_if_exists(:party_group_suggestions,  "chk_group_suggestions_evidence")
    drop_check_if_exists(:party_link_suggestions,   "chk_link_suggestions_evidence")
    # (don’t recreate the generic `evidence` checks on down; unnecessary)
  end

  private

  def mysql_or_mariadb?
    adapter = ActiveRecord::Base.connection.adapter_name
    adapter =~ /mysql/i
  end

  def fix_check(table, new_name)
    # 1) drop any existing anonymous/duplicate “evidence” check
    drop_check_if_exists(table, "evidence")

    # 2) (re)add the check with a unique name if missing
    unless check_exists?(table, new_name)
      execute <<~SQL
        ALTER TABLE #{table}
        ADD CONSTRAINT #{new_name}
        CHECK (json_valid(`evidence`));
      SQL
    end
  end

  def drop_check_if_exists(table, name)
    return unless check_exists?(table, name)
    # MariaDB / MySQL 8 both accept DROP CHECK / DROP CONSTRAINT for checks
    execute "ALTER TABLE #{table} DROP CHECK #{name};"
  rescue ActiveRecord::StatementInvalid
    execute "ALTER TABLE #{table} DROP CONSTRAINT #{name};"
  end

  def check_exists?(table, name)
    # Works on MySQL >= 8.0 and MariaDB: INFORMATION_SCHEMA.CHECK_CONSTRAINTS
    sql = <<~SQL
      SELECT COUNT(*)
      FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS cc
      JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
        ON cc.CONSTRAINT_SCHEMA = tc.CONSTRAINT_SCHEMA
       AND cc.CONSTRAINT_NAME   = tc.CONSTRAINT_NAME
      WHERE tc.TABLE_SCHEMA = DATABASE()
        AND tc.TABLE_NAME   = '#{table}'
        AND cc.CONSTRAINT_NAME = '#{name}';
    SQL
    ActiveRecord::Base.connection.select_value(sql).to_i > 0
  end
end
