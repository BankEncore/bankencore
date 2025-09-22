module Party
  class Group < ApplicationRecord
    self.table_name = "party_groups"

    belongs_to :group_type, class_name: "Ref::PartyGroupType",
           foreign_key: "party_group_type_code", primary_key: "code",
           optional: true

    has_many :group_memberships, class_name: "Party::GroupMembership",
              foreign_key: :group_id, dependent: :destroy

    has_many :parties, through: :group_memberships, class_name: "Party::Party"

    validates :name, presence: true
  end
end
