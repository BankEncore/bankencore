module Ref
  class PhoneType < ApplicationRecord
    self.table_name  = "ref_phone_types"
    self.primary_key = "code"

    has_many :phones,
      class_name: "Party::Phone",
      foreign_key: :phone_type_code,
      primary_key: :code,
      inverse_of: :phone_type,
      dependent: :restrict_with_error

    validates :code, presence: true
    validates :name, presence: true
  end
end
