module Ref
  class PartyLinkType < ApplicationRecord
    self.table_name  = "ref_party_link_types"
    self.primary_key = "code"

    has_many :links,
      class_name: "Party::Link",
      foreign_key: :party_link_type_code,
      primary_key: :code,
      inverse_of: :party_link_type,
      dependent: :restrict_with_error

    validates :code, presence: true
    validates :name, presence: true

    def symmetric? = !!self[:symmetric]
  end
end
