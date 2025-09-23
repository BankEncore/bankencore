module Party
  class Address < ApplicationRecord
    self.table_name = "party_addresses"
    include SinglePrimary

    belongs_to :party, class_name: "Party::Party", foreign_key: :party_id, inverse_of: :addresses

    belongs_to :address_type, class_name: "Ref::AddressType",
               foreign_key: :address_type_code, primary_key: :code

    belongs_to :country, class_name: "Ref::Country", foreign_key: "country_code", primary_key: "code"
    belongs_to :region,  class_name: "Ref::Region",  foreign_key: "region_code",  primary_key: "code", optional: true

    before_validation { self.country_code ||= "US" }
    validates :country_code, presence: true
    validates :address_type_code, presence: true
  end
end
