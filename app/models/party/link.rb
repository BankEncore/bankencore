# app/models/party/link.rb
module Party
  class Link < ApplicationRecord
    self.table_name = "party_links"

    belongs_to :source_party, class_name: "Party::Party"
    belongs_to :target_party, class_name: "Party::Party"
    belongs_to :party_link_type,
               class_name:  "Ref::PartyLinkType",
               foreign_key: :party_link_type_code,
               primary_key: :code

    # ---- scopes ----
    scope :active,     -> { where("started_on IS NULL OR started_on <= ?", Date.current)
                              .where("ended_on   IS NULL OR ended_on   >= ?", Date.current) }
    scope :between,    ->(from, to) {
      where("(started_on IS NULL OR started_on <= ?) AND (ended_on IS NULL OR ended_on >= ?)", to, from)
    }
    scope :of_type,    ->(code) { where(party_link_type_code: code) }
    scope :involving,  ->(party_id) { where("source_party_id = ? OR target_party_id = ?", party_id, party_id) }

    # ---- validations ----
    validates :source_party_id, :target_party_id, :party_link_type_code, presence: true
    validate  :no_self_link
    validate  :dates_in_order
    validate  :no_duplicate_interval

    # ---- callbacks ----
    after_commit :ensure_inverse!, on: :create

    # ---- helpers ----
    def symmetric? = party_link_type&.symmetric?
    def inverse_code = party_link_type&.inverse_code

    private

    def no_self_link
      errors.add(:base, "source and target cannot be the same party") if source_party_id.present? && source_party_id == target_party_id
    end

    def dates_in_order
      return if started_on.blank? || ended_on.blank?
      errors.add(:ended_on, "must be on or after started_on") if ended_on < started_on
    end

    # Prevent another link of same logical pair + type overlapping this link.
    # For symmetric types, treat (A,B) and (B,A) as the same pair.
    def no_duplicate_interval
      a, b = source_party_id, target_party_id
      return if a.blank? || b.blank? || party_link_type_code.blank?

      scope = self.class.where(party_link_type_code: party_link_type_code)
      if symmetric?
        scope = scope.where(
          "(source_party_id = :a AND target_party_id = :b) OR (source_party_id = :b AND target_party_id = :a)",
          a:, b:
        )
      else
        scope = scope.where(source_party_id: a, target_party_id: b)
      end
      scope = scope.where.not(id: id) if persisted?

      # overlap test: (other.start <= this.end) AND (other.end >= this.start), with NULL as open interval
      s = started_on || Date.new(0)
      e = ended_on   || Date.new(9999, 12, 31)
      if scope.where("(COALESCE(started_on, '0001-01-01') <= ?) AND (COALESCE(ended_on, '9999-12-31') >= ?)", e, s).exists?
        errors.add(:base, "duplicate relationship for the same interval")
      end
    end

    # Create or align the inverse link for directed types.
    def ensure_inverse!
      return if symmetric?
      return if inverse_code.blank?

      inv = self.class.find_or_initialize_by(
        source_party_id: target_party_id,
        target_party_id: source_party_id,
        party_link_type_code: inverse_code,
        started_on: started_on,
        ended_on: ended_on
      )
      inv.save! if inv.new_record?
    end
  end
end
