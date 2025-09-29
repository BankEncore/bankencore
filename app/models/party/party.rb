# app/models/party/party.rb
module Party
  class Party < ApplicationRecord
    self.table_name = "parties"

    # Associations
    has_one  :person,       class_name: "Party::Person",       inverse_of: :party, dependent: :destroy
    has_one  :organization, class_name: "Party::Organization", inverse_of: :party, dependent: :destroy
    has_many :addresses,    class_name: "Party::Address",      inverse_of: :party, dependent: :destroy
    has_many :emails,       class_name: "Party::Email",        inverse_of: :party, dependent: :destroy
    has_many :phones,       class_name: "Party::Phone",        inverse_of: :party, dependent: :destroy
    has_many :identifiers,  class_name: "::Party::Identifier", inverse_of: :party, dependent: :destroy

    # Nested attrs
    accepts_nested_attributes_for :person, allow_destroy: true
    accepts_nested_attributes_for :organization, allow_destroy: true
    accepts_nested_attributes_for :addresses, allow_destroy: true, reject_if: ->(h) {
      %i[line1 line2 line3 locality region_code postal_code country_code].all? { |k| h[k].to_s.strip.blank? }
    }
    accepts_nested_attributes_for :emails, allow_destroy: true, reject_if: ->(h) { h["email"].to_s.strip.blank? }
    accepts_nested_attributes_for :phones, allow_destroy: true, reject_if: ->(h) {
      h["id"].blank? && h["number_raw"].to_s.strip.blank? && h["phone_e164"].to_s.strip.blank? && h["phone_ext"].to_s.strip.blank?
    }
    accepts_nested_attributes_for :identifiers, allow_destroy: true,
      reject_if: ->(h) { h["id"].present? && h["value"].to_s.strip.blank? }

    # Virtuals for simple form binding
    attr_accessor :tax_id_input, :tax_id_type  # "ssn","ein","itin","foreign_tin"
    before_save :sync_tax_identifier_from_virtual

    phones_attrs = [:id, :phone_type_code, :phone_e164, :phone_ext, :consent_sms, :is_primary, :_destroy]

    # Callbacks
    before_validation :ensure_public_id
    before_validation :ensure_customer_number

    # Validations
    validates :public_id,       presence: true, uniqueness: true
    validates :customer_number, presence: true, uniqueness: true

    # Display helpers
    def display_name
      if person
        [person.first_name, person.middle_name, person.last_name, person.name_suffix].compact_blank.join(" ")
      elsif organization
        organization.display_name
      else
        "(Unnamed Party)"
      end
    end

    def to_param = public_id
    def primary_email   = emails.find { |e| e.is_primary? } || emails.first
    def primary_address = addresses.find { |a| a.is_primary? } || addresses.first
    def primary_phone   = phones.first

    def primary_tax_id
      identifiers.where(id_type_code: %w[ssn itin ein foreign_tin]).find_by(is_primary: true)
    end

    def sync_tax_identifier_from_virtual
      return if tax_id_input.blank? || tax_id_type.blank?
      rec = identifiers.find_or_initialize_by(id_type_code: tax_id_type, is_primary: true)
      rec.value = tax_id_input
    end

    # Guardrails: prevent writing legacy columns if they still exist
    def tax_id=(_v)
      raise "tax_id is deprecated; write Party::Identifier"
    end

    def tax_id_bidx=(_v)
      raise "tax_id_bidx is deprecated"
    end

    private

    def ensure_public_id
      self.public_id = SecureRandom.uuid if public_id.blank?
    end

    def ensure_customer_number
      return if customer_number.present?
      5.times do
        candidate =
          if defined?(CustomerNumber::Generator) && CustomerNumber::Generator.respond_to?(:call)
            CustomerNumber::Generator.call.to_s.strip
          else
            ""
          end
        next if candidate.blank?
        unless self.class.exists?(customer_number: candidate)
          self.customer_number = candidate
          return
        end
      end
      loop do
        fallback = "C#{Time.current.strftime('%y%m%d')}#{format('%06d', SecureRandom.random_number(1_000_000))}"
        break(self.customer_number = fallback) unless self.class.exists?(customer_number: fallback)
      end
    end
  end
end
