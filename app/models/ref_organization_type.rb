class RefOrganizationType < ApplicationRecord
  self.primary_key = "code"

  has_many :party_organizations, class_name: "Party::Organization", foreign_key: "organization_type_code", primary_key: "code"

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end
