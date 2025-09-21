class EnsurePublicIdUuidOnParties < ActiveRecord::Migration[8.0]
  def up
    change_column :parties, :public_id, :string, limit: 36
    execute <<~SQL
      UPDATE parties
      SET public_id = (SELECT UUID())
      WHERE public_id IS NULL OR public_id = '';
    SQL
    change_column_null :parties, :public_id, false

    add_index :parties, :public_id, unique: true unless index_exists?(:parties, :public_id)
  end

  def down
    change_column_null :parties, :public_id, true
    remove_index :parties, :public_id if index_exists?(:parties, :public_id)
  end
end
