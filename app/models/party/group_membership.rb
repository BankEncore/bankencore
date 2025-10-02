# app/models/party/group_membership.rb
module Party
  class GroupMembership < ApplicationRecord
    self.table_name = "party_group_memberships"

    belongs_to :party, class_name: "Party::Party",
              foreign_key: :party_id, inverse_of: :group_memberships
    belongs_to :group, class_name: "Party::Group",
              foreign_key: :group_id,  inverse_of: :group_memberships

    # Optional: role_code can be NULL or a small ref table later.
    validates :party_id, :group_id, presence: true
    validate  :dates_in_order
    validate  :no_duplicate_interval

    scope :active, -> {
      where("started_on IS NULL OR started_on <= ?", Date.current)
        .where("ended_on   IS NULL OR ended_on   >= ?", Date.current)
    }

    private

    def dates_in_order
      return if started_on.blank? || ended_on.blank?
      errors.add(:ended_on, "must be on or after started_on") if ended_on < started_on
    end

    # Prevent overlapping duplicate membership rows for same party+group+role_code
    def no_duplicate_interval
      scope = self.class.where(group_id:, party_id:)
      scope = scope.where(role_code: role_code)
      scope = scope.where.not(id: id) if persisted?

      s = started_on || Date.new(0)
      e = ended_on   || Date.new(9999, 12, 31)
      if scope.where("(COALESCE(started_on, '0001-01-01') <= ?) AND (COALESCE(ended_on, '9999-12-31') >= ?)", e, s).exists?
        errors.add(:base, "duplicate membership for the same interval")
      end
    end
  end
end
