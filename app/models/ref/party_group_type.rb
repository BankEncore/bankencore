module Ref
  class PartyGroupType < ApplicationRecord
    self.table_name  = "ref_party_group_types"
    self.primary_key = "code"

    has_many :groups,
      class_name: "Party::Group",
      foreign_key: :party_group_type_code,
      primary_key: :code,
      inverse_of: :party_group_type,
      dependent: :restrict_with_error

    validates :code, presence: true
    validates :name, presence: true
  end
end