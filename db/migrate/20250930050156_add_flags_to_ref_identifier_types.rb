class AddFlagsToRefIdentifierTypes < ActiveRecord::Migration[7.2]
  def change
    add_column :ref_identifier_types, :person_only, :boolean, default: false, null: false
    add_column :ref_identifier_types, :organization_only, :boolean, default: false, null: false
  end
end
