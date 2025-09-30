# app/models/party/identifier.rb
module Party
  class Identifier < ApplicationRecord
    include PrimaryFirst
    self.table_name = "party_identifiers"

    belongs_to :party, class_name: "::Party::Party"
    belongs_to :identifier_type, class_name: "::Ref::IdentifierType"

    encrypts :value, deterministic: true
    blind_index :value, key: BlindIndex.master_key, encode: false

    # Scopes
    scope :primary, -> { where(is_primary: true) }
    scope :tax_ids, -> {
      joins(:identifier_type).where(ref_identifier_types: { code: %w[ssn itin ein foreign_tin] })
    }

    # Validations
    validates :identifier_type, presence: true
    validates :value, presence: true
    validate  :single_primary_per_type
    validate  :no_duplicate_identifier
    validate  :issuer_requirements

    # Callbacks
    before_validation :normalize_value
    before_validation :sync_legacy_code
    before_save       :set_mask

    # Convenience
    def id_type_code = identifier_type&.code

    # -------- private ------------------------------------------------------
    private

    # Normalization helper (class-level for reuse)
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

    def set_mask
      return unless value.present? && identifier_type
      self.value_masked =
        case identifier_type.mask_rule
        when "ssn"   then "***-**-#{value[-4, 4]}"
        when "ein"   then "#{value[0, 2]}-******"
        when "last4" then "****#{value[-4, 4]}"
        else "****"
        end
    end

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
