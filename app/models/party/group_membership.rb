module Party
  class GroupMembership < ApplicationRecord
    self.table_name = "party_group_memberships"

    belongs_to :party, class_name: "Party::Party", foreign_key: :party_id
    belongs_to :group, class_name: "Party::Group", foreign_key: :group_id

    validates :party_id, presence: true
    validates :group_id, presence: true
  end
end
