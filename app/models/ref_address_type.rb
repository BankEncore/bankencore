class RefAddressType < ApplicationRecord
  self.primary_key = "code"

  has_many :party_addresses, class_name: "Party::Address", foreign_key: "address_type_code", primary_key: "code"

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end
