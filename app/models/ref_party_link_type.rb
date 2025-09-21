class RefPartyLinkType < ApplicationRecord
  self.primary_key = "code"

  has_many :party_links, class_name: "Party::Link", foreign_key: "party_link_type_code", primary_key: "code"

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  # Maybe some logic for symmetric / inverse link types as needed
end
