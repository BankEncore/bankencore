module Party
  class Organization < ApplicationRecord
    self.primary_key = "party_id"
    self.table_name = "party_organizations"

    belongs_to :party, class_name: "Party::Party", foreign_key: :party_id

    belongs_to :organization_type, class_name: "RefOrganizationType",
           foreign_key: :organization_type_code, primary_key: :code,
           optional: true


    validates :legal_name, presence: true
  end
end
