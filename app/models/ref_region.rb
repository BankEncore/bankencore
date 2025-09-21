class RefRegion < ApplicationRecord
  self.primary_key = "code"

  belongs_to :country, class_name: "RefCountry", foreign_key: "country_code", primary_key: "code"

  has_many :party_addresses, class_name: "Party::Address", foreign_key: "region_code", primary_key: "code"

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :country_code, presence: true, length: { is: 2 }
end
