# app/models/party/group_suggestion.rb
class Party::GroupSuggestion < ApplicationRecord
  self.table_name = "party_group_suggestions"

  belongs_to :reviewed_by, class_name: "Internal::User", optional: true

  validates :group_type_code, presence: true
  validates :members, presence: true
  validates :confidence_score, numericality: { in: 0.0..1.0 }
  validate  :members_compatibility

  scope :pending, -> { where(reviewed_flag: false) }

  def member_party_ids
    Array(members).map { |m| m.symbolize_keys[:party_id] }.compact
  end

  def members_compatibility
    gt = Ref::PartyGroupType.find_by(code: group_type_code)
    return errors.add(:group_type_code, "unknown") unless gt
    allowed = Array(gt.allowed_party_types)
    Array(members).each do |m|
      p = Party::Party.find_by(id: m["party_id"] || m[:party_id])
      next errors.add(:members, "party missing") unless p
      errors.add(:members, "party type not allowed") unless allowed.include?(p.party_type)
    end
  end
end
