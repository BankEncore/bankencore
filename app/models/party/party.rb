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
    has_many :screenings,   class_name: "Party::Screening",    inverse_of: :party, dependent: :destroy

    has_many :source_links,
      class_name: "::Party::Link",
      foreign_key: :source_party_id,
      inverse_of: :source_party,
      dependent: :destroy

    has_many :target_links,
      class_name: "::Party::Link",
      foreign_key: :target_party_id,
      inverse_of: :target_party,
      dependent: :destroy

    has_many :group_memberships, class_name: "Party::GroupMembership",
            foreign_key: :party_id, inverse_of: :party, dependent: :destroy
    has_many :groups, through: :group_memberships, class_name: "Party::Group"

    # Nested attrs
    accepts_nested_attributes_for :person,       allow_destroy: true
    accepts_nested_attributes_for :organization, allow_destroy: true

    accepts_nested_attributes_for :addresses,
      allow_destroy: true,
      reject_if: ->(h) {
        %i[line1 line2 line3 locality region_code postal_code country_code].all? { |k| h[k].to_s.strip.blank? }
      }

    accepts_nested_attributes_for :emails,
      allow_destroy: true,
      reject_if: ->(h) { h["email"].to_s.strip.blank? }

    accepts_nested_attributes_for :phones,
      allow_destroy: true,
      reject_if: ->(h) {
        %w[phone_e164 phone_ext phone_type_code].all? { |k| h[k].to_s.strip.blank? }
      }

    # One definition only. Do NOT use update_only for has_many.
    accepts_nested_attributes_for :identifiers,
      allow_destroy: true,
      reject_if: ->(h) {
        # drop brand-new empty rows, but allow edits to existing rows even if value blank (controller scrubber preserves old value)
        h["id"].blank? &&
          %w[value id_type_code country_code issuing_authority issued_on expires_on is_primary].all? { |k| h[k].to_s.strip.blank? }
      }

    after_initialize do
      build_person if new_record? && person.nil?
    end

    # Virtuals for simple form binding
    attr_accessor :tax_id_input, :tax_id_type  # "ssn","ein","itin","foreign_tin"
    before_save :sync_tax_identifier_from_virtual

    phones_attrs = [ :id, :phone_type_code, :phone_e164, :phone_ext, :consent_sms, :is_primary, :_destroy ]

    # Callbacks
    before_validation :ensure_public_id
    before_validation :ensure_customer_number

    # Validations
    validates :public_id,       presence: true, uniqueness: true
    validates :customer_number, presence: true, uniqueness: true

    # Display helpers
    def display_name
      if person
        [ person.first_name, person.middle_name, person.last_name, person.name_suffix ].compact_blank.join(" ")
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

    def ensure_identifier_stub
      return if identifiers.tax_ids.where(is_primary: true).exists?
      code = organization.present? ? "ein" : "ssn"
      type = ::Ref::IdentifierType.find_by!(code: code)
      identifiers.build(identifier_type: type, is_primary: true)
    end

    def links
      ::Party::Link.involving(id)
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

    def scrub_identifier_params(attrs)
      attrs = attrs.is_a?(ActionController::Parameters) ? attrs.to_h : attrs
      ihash = attrs.deep_dup[:identifiers_attributes]
      return attrs unless ihash.is_a?(Hash)

      cleaned = ihash.values.map { |h| h.symbolize_keys }
      cleaned.each do |h|
        h[:value_len] = h.delete(:len) if h.key?(:len) && !h.key?(:value_len)
        h.delete(:value) if h[:id].present? && h[:value].to_s.strip.blank?
      end

      content_keys = %i[id_type_code value value_len country_code issuing_authority issued_on expires_on is_primary]
      cleaned.select! { |h| h[:id].present? || content_keys.any? { |k| h[k].to_s.strip.present? } }
      attrs[:identifiers_attributes] = cleaned.each_with_index.to_h { |h, i| [ i.to_s, h ] }
      attrs
    end
  end
end
