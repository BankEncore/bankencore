# app/models/party/group.rb
class Party::Group < ApplicationRecord
  self.table_name = "party_groups"
  belongs_to :group_type, class_name: "Ref::PartyGroupType",
             foreign_key: :party_group_type_code, primary_key: :code, optional: true
  has_many :group_memberships, class_name: "Party::GroupMembership",
           foreign_key: :group_id, inverse_of: :group, dependent: :destroy
  has_many :parties, through: :group_memberships, class_name: "Party::Party"
  validates :name, presence: true

    scope :of_type, ->(code) {
      code.present? ? where(party_group_type_code: code) : all
    }
end
# replaces current minimal version 【4:review_bundle.txt†L44-L50】
