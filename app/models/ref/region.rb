module Ref
  class Region < ApplicationRecord
    self.table_name  = "ref_regions"
    self.primary_key = "code"

    belongs_to :country,
      class_name: "Ref::Country",
      foreign_key: :country_code,
      primary_key: :code,
      inverse_of: :regions,
      optional: false

    has_many :addresses,
      class_name: "Party::Address",
      foreign_key: :region_code,
      primary_key: :code,
      inverse_of: :region,
      dependent: :restrict_with_error

    validates :code, presence: true
    validates :name, presence: true
    validates :country_code, presence: true
  end
end