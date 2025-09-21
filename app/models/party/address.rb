module Party
  class Address < ApplicationRecord
    self.table_name = "party_addresses"

    belongs_to :party, class_name: "Party::Party", foreign_key: :party_id

    belongs_to :address_type, class_name: "RefAddressType",
               foreign_key: :address_type_code, primary_key: :code

    belongs_to :country, class_name: "RefCountry", foreign_key: "country_code", primary_key: "code"
    belongs_to :region,  class_name: "RefRegion",  foreign_key: "region_code",  primary_key: "code", optional: true

    before_validation { self.country_code ||= "US" }
    validates :country_code, presence: true
    validates :address_type_code, presence: true
  end
end
