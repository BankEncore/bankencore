# app/models/party/identifier.rb
module Party
  class Identifier < ApplicationRecord
    self.table_name = "party_identifiers"
    belongs_to :party, class_name: "Party::Party"

    enum :id_type_code, {
      ssn: "ssn", itin: "itin", ein: "ein", foreign_tin: "foreign_tin",
      passport: "passport", dl: "dl", lei: "lei"
    }

    encrypts :value, deterministic: true

    # Class helper used by blind_index and callbacks
    def self.normalize(raw, id_type)
      v = raw.to_s.strip
      case id_type.to_s
      when "ssn", "itin", "ein", "foreign_tin" then v.gsub(/\W/, "")
      when "lei", "passport", "dl"             then v.upcase.gsub(/\s+/, "")
      else v.upcase.gsub(/\s+/, "")
      end
    end

    blind_index :value, key: BlindIndex.master_key, encode: false

    validates :id_type_code, presence: true
    validates :value, presence: true
    validate  :single_primary_per_type
    validate :no_duplicate_identifier

    before_validation :apply_normalization
    before_save :set_mask

    scope :primary, -> { where(is_primary: true) }
    scope :tax_ids, -> { where(id_type_code: %w[ssn itin ein foreign_tin]) }

    private

    def apply_normalization
      self.value = self.class.normalize(value, id_type_code) if value.present?
    end

    def set_mask
      return unless value.present?
      self.value_masked =
        case id_type_code
        when "ssn", "itin" then "***-**-#{value[-4, 4]}"
        when "ein"        then "#{value[0, 2]}-******"
        when "passport","dl","lei" then "****#{value[-4,4]}"
        else "****"
        end
    end

    def single_primary_per_type
      return unless is_primary?
      exists = self.class.where(party_id:, id_type_code:, is_primary: true).where.not(id: id).exists?
      errors.add(:is_primary, "already set for this type") if exists
    end

    def no_duplicate_identifier
      return if value.blank? || id_type_code.blank?
      norm = self.class.normalize(value, id_type_code)
      bidx = BlindIndex.generate_bidx(norm, key: BlindIndex.master_key, encode: false)
      exists = self.class.where(id_type_code:, value_bidx: bidx).where.not(id: id).exists?
      errors.add(:value, "is already in use by another profile") if exists
    end
  end
end
