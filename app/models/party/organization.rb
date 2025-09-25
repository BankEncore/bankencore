module Party
  class Organization < ApplicationRecord
    self.primary_key = "party_id"
    self.table_name = "party_organizations"

    belongs_to :party, class_name: "Party::Party", foreign_key: :party_id

    belongs_to :organization_type, class_name: "Ref::OrganizationType",
           foreign_key: :organization_type_code, primary_key: :code,
           optional: true

    before_validation do
      self.legal_name = legal_name&.strip
      self.operating_name = operating_name&.strip
    end

    validates :legal_name, presence: true

    def display_name
      return legal_name.to_s if operating_name.blank?
      "#{legal_name} d/b/a #{operating_name}"
    end
  end
end
