# db/migrate/20250928_identifiers_guardrails.rb
class IdentifiersGuardrails < ActiveRecord::Migration[8.0]
  def change
    # Optional: speed up lookups by old bidx during transition
    add_index :parties, :tax_id_bidx unless index_exists?(:parties, :tax_id_bidx)
  end
end
