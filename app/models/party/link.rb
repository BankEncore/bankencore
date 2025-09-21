module Party
  class Link < ApplicationRecord
    self.table_name = "party_links"

    belongs_to :source_party, class_name: "Party::Party", foreign_key: :source_party_id
    belongs_to :target_party, class_name: "Party::Party", foreign_key: :target_party_id

    belongs_to :link_type, class_name: "RefPartyLinkType",
               foreign_key: :party_link_type_code, primary_key: :code

    validates :party_link_type_code, presence: true

    # Optional: validations to prevent loops or self-linking
    validate :source_and_target_cannot_be_same

    def source_and_target_cannot_be_same
      errors.add(:target_party_id, "can't be same as source") if source_party_id == target_party_id
    end
  end
end
