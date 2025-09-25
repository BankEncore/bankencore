# db/migrate/20250923000000_add_operating_name_to_party_organizations.rb
class AddOperatingNameToPartyOrganizations < ActiveRecord::Migration[7.1]
  def change
    add_column :party_organizations, :operating_name, :string
  end
end
