# app/models/party/group_membership.rb
module Party
  class GroupMembership < ApplicationRecord
    self.table_name = "party_group_memberships"

    belongs_to :party, class_name: "Party::Party",  inverse_of: :group_memberships
    belongs_to :group, class_name: "Party::Group",  inverse_of: :group_memberships

    # role_code optional; validate against catalog only if present
    validates :party_id, :group_id, presence: true
    validate  :dates_in_order
    validate  :no_duplicate_interval
    validate  :role_and_party_type_allowed

    scope :active, -> {
      where("started_on IS NULL OR started_on <= ?", Date.current)
        .where("ended_on   IS NULL OR ended_on   >= ?", Date.current)
    }

    private

    def dates_in_order
      return if started_on.blank? || ended_on.blank?
      errors.add(:ended_on, "must be on or after started_on") if ended_on < started_on
    end

    # Prevent overlapping duplicate membership rows for same party+group(+role)
    def no_duplicate_interval
      gid = self[:group_id]
      pid = self[:party_id]
      return if gid.blank? || pid.blank?

      scope = self.class.where(group_id: gid, party_id: pid)
      scope = scope.where.not(id: id) if persisted?
      scope = scope.where(role_code: self[:role_code]) if self.class.column_names.include?("role_code")

      s = started_on || Date.new(0)
      e = ended_on   || Date.new(9999, 12, 31)

      if scope.where("(COALESCE(started_on,'0001-01-01') <= ?) AND (COALESCE(ended_on,'9999-12-31') >= ?)", e, s).exists?
        errors.add(:base, "overlapping membership for same party and group")
      end
    end

    # Enforce catalog rules when available.
    # - role_code must be in allowed_group_roles if provided.
    # - party.party_type must be in allowed_party_types.
    def role_and_party_type_allowed
      gt = group&.group_type
      return unless gt

      roles = to_array(gt[:allowed_group_roles]).map!(&:to_s)
      types = to_array(gt[:allowed_party_types]).map!(&:to_s)

      if self.class.column_names.include?("role_code") && role_code.present? && roles.any? && !roles.include?(role_code.to_s)
        errors.add(:role_code, "not allowed for #{gt.code}")
      end

      ptype = party&.party_type || ::Party::Party.where(id: self[:party_id]).limit(1).pick(:party_type)
      if ptype.present? && types.any? && !types.include?(ptype.to_s)
        errors.add(:party_id, "party_type #{ptype} not allowed for #{gt.code}")
      end
    end

    def to_array(v)
      return v if v.is_a?(Array)
      return JSON.parse(v) rescue v.to_s.split(",").map(&:strip) if v.is_a?(String)
      []
    end
  end
end
