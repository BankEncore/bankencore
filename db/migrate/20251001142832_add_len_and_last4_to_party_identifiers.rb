# db/migrate/20251001000000_add_len_and_last4_to_party_identifiers.rb
class AddLenAndLast4ToPartyIdentifiers < ActiveRecord::Migration[7.2]
  def change
    add_column :party_identifiers, :value_len,   :integer
    add_column :party_identifiers, :value_last4, :string, limit: 4
  end
end
