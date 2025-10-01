module Party
  class Identifier < ApplicationRecord
    include PrimaryFirst
    self.table_name = "party_identifiers"

    belongs_to :party,            class_name: "::Party::Party"
    belongs_to :identifier_type,  class_name: "::Ref::IdentifierType"

    encrypts :value, deterministic: true
    blind_index :value, key: BlindIndex.master_key, encode: false

    scope :primary, -> { where(is_primary: true) }
    scope :tax_ids, -> {
      joins(:identifier_type).where(ref_identifier_types: { code: %w[ssn itin ein foreign_tin] })
    }

    validates :identifier_type, presence: true
    validates :value, presence: true
    validates :value_len, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :value_last4, length: { maximum: 4 }, allow_nil: true
    validate  :single_primary_per_type
    validate  :no_duplicate_identifier
    validate  :issuer_requirements

    # NEW
    before_validation :normalize_value
    before_validation :sync_legacy_code
    before_validation :derive_len_last4   # NEW
    # REMOVED: before_save :set_mask

    # Convenience
    def id_type_code = identifier_type&.code

    # Public display API (use these in views)


    def masked(keep: 4, mask: "•")
      len = value_len.to_i
      return "" if len <= 0
      k = [ keep, len ].min
      mask * (len - k) + value_last4.to_s.last(k)
    end

    def masked_formatted
      rule = identifier_type&.mask_rule.to_s

      case rule
      when "ssn"     # 9 digits → •••-••-1234
        (value_len == 9 && value_last4.present?) ? "•••-••-#{value_last4}" : masked
      when "ein"     # policy: hide prefix completely
        masked
      when "last4"   # generic last4
        masked
      when /\Apattern:(\d+)-(\d+)-(\d+)\z/ # e.g. "pattern:3-2-4"
        g1, g2, g3 = [ $1, $2, $3 ].map!(&:to_i)
        return masked if value_len != (g1+g2+g3) || value_last4.blank?
        # Only reveal last group’s last digits
        "•" * g1 + "-" + "•" * g2 + "-" + value_last4.rjust(g3, "•")
      when "none"    # show nothing
        ""
      else
        masked       # default
      end
    end

    # Legacy shim
    def value_masked = masked_formatted

    # Normalization helper (unchanged)
    def self.normalize(raw, type_or_code)
      code = type_or_code.is_a?(::Ref::IdentifierType) ? type_or_code.code : type_or_code.to_s
      v = raw.to_s.strip
      case code
      when "ssn", "itin", "ein", "foreign_tin" then v.gsub(/\W/, "")
      when "lei", "passport", "dl"            then v.upcase.gsub(/\s+/, "")
      else v
      end
    end

    def normalize_value
      return unless value.present? && identifier_type
      self.value = self.class.normalize(value, identifier_type)
    end

    # NEW: derive cached length and last4 from plaintext `value`
    def derive_len_last4
      return unless value.present?
      d = value.to_s.gsub(/\D/, "")
      self.value_len   = d.length
      self.value_last4 = d.last(4).presence
    end

    # REMOVED: set_mask (we no longer persist masked strings)

    def issuer_requirements
      return unless identifier_type
      if identifier_type.require_issuer_country && country_code.blank?
        errors.add(:country_code, "is required for #{identifier_type.name}")
      end
      if identifier_type.require_issuer_region && issuing_authority.blank?
        errors.add(:issuing_authority, "is required for #{identifier_type.name}")
      end
    end

    def single_primary_per_type
      return unless is_primary? && identifier_type_id.present?
      exists = self.class.where(party_id:, identifier_type_id:, is_primary: true)
                         .where.not(id: id).exists?
      errors.add(:is_primary, "already set for this type") if exists
    end

    def no_duplicate_identifier
      return unless value.present? && identifier_type_id.present?
      norm = self.class.normalize(value, identifier_type)
      bidx = BlindIndex.generate_bidx(norm, key: BlindIndex.master_key, encode: false)
      taken = self.class.where(identifier_type_id:, value_bidx: bidx)
                        .where.not(id: id).exists?
      errors.add(:value, "is already in use by another profile") if taken
    end

    def sync_legacy_code
      return unless has_attribute?(:id_type_code)
      self.id_type_code = identifier_type&.code
    end
  end
end
