module Ref
  class AddressType < ApplicationRecord
    self.table_name  = "ref_address_types"
    self.primary_key = "code"

    has_many :addresses,
      class_name: "Party::Address",
      foreign_key: :address_type_code,
      primary_key: :code,
      inverse_of: :address_type,
      dependent: :restrict_with_error

    validates :code, presence: true
    validates :name, presence: true
  end
end
