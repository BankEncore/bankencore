module Party
  class Address < ApplicationRecord
    include SinglePrimary
    self.table_name = "party_addresses"

    belongs_to :party, class_name: "Party::Party", inverse_of: :addresses

    belongs_to :address_type, class_name: "Ref::AddressType",
               foreign_key: :address_type_code, primary_key: :code

    belongs_to :country, class_name: "Ref::Country",
               foreign_key: :country_code,  primary_key: :code

    # scope region by country_code to match the FK
    belongs_to :region, ->(addr) { where(country_code: addr.country_code) },
               class_name: "Ref::Region",
               foreign_key: :region_code, primary_key: :code, optional: true

    # normalize before validations
    before_validation { self.country_code = (country_code.presence || "US").to_s.upcase.strip }
    before_validation { self.region_code  = region_code.to_s.upcase.strip }
    before_validation :normalize_codes

    validates :country_code,      presence: true
    validates :address_type_code, presence: true

    private

    def normalize_codes
      self.region_code = nil if region_code.blank?
    end
  end
end
