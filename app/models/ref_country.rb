class RefCountry < ApplicationRecord
  self.primary_key = "code"

  has_many :ref_regions, class_name: "RefRegion", foreign_key: "country_code", primary_key: "code"
  has_many :party_addresses, class_name: "Party::Address", foreign_key: "country_code", primary_key: "code"

  validates :code, presence: true, uniqueness: true, length: { is: 2 }
  validates :name, presence: true
end
