class RefPartyGroupType < ApplicationRecord
  self.primary_key = "code"

  has_many :party_groups, class_name: "Party::Group", foreign_key: "party_group_type_code", primary_key: "code"

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end
