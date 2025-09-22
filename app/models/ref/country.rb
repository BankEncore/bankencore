module Ref
  class Country < ApplicationRecord
    self.table_name  = "ref_countries"
    self.primary_key = "code"

    has_many :regions,
      class_name: "Ref::Region",
      foreign_key: :country_code,
      primary_key: :code,
      inverse_of: :country,
      dependent: :restrict_with_error

    has_many :addresses,
      class_name: "Party::Address",
      foreign_key: :country_code,
      primary_key: :code,
      inverse_of: :country,
      dependent: :restrict_with_error

    validates :code, presence: true
    validates :name, presence: true
  end
end