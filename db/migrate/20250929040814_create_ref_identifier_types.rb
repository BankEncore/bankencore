# db/migrate/20250929_create_ref_identifier_types.rb
class CreateRefIdentifierTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :ref_identifier_types do |t|
      t.string  :code, null: false          # ssn, ein, itin, foreign_tin, passport, dl, lei
      t.string  :name, null: false          # display
      t.integer :sort_order, null: false, default: 100
      t.boolean :require_issuer_country, null: false, default: false
      t.boolean :require_issuer_region,  null: false, default: false
      t.string  :normalize_rule            # "digits" | "uppercase_nospaces" | nil
      t.string  :mask_rule                 # "ssn" | "ein" | "last4" | "fixed"
      t.timestamps
    end
    add_index :ref_identifier_types, :code, unique: true
  end
end
