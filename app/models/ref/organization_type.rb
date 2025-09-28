module Ref
  class OrganizationType < ApplicationRecord
    self.table_name  = "ref_organization_types"
    self.primary_key = "code"

    has_many :organizations,
      class_name: "Party::Organization",
      foreign_key: :organization_type_code,
      primary_key: :code,
      inverse_of: :organization_type,
      dependent: :restrict_with_error

    validates :code, presence: true
    validates :name, presence: true
  end
end
