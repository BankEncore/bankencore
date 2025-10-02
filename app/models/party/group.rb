# app/models/party/group.rb
module Party
  class Group < ApplicationRecord
    self.table_name = "party_groups"

    has_many :group_memberships, class_name: "Party::GroupMembership",
            foreign_key: :group_id, inverse_of: :group, dependent: :destroy
    has_many :parties, through: :group_memberships, class_name: "Party::Party"
        has_many :parties, through: :group_memberships, class_name: "Party::Party"

    validates :name, presence: true
  end
end
