# app/models/party/party.rb
module Party
  class Party < ApplicationRecord
    self.table_name = "parties"

    # Sensitive fields
    encrypts :tax_id, deterministic: true
    blind_index :tax_id, key: BlindIndex.master_key, encode: false

    # Associations
    has_one  :person,       class_name: "Party::Person",       inverse_of: :party, dependent: :destroy
    has_one  :organization, class_name: "Party::Organization", inverse_of: :party, dependent: :destroy
    has_many :addresses,    class_name: "Party::Address",      inverse_of: :party, dependent: :destroy
    has_many :emails,       class_name: "Party::Email",        inverse_of: :party, dependent: :destroy
    has_many :phones,       class_name: "Party::Phone",        inverse_of: :party, dependent: :destroy

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

    # Callbacks
    before_validation :ensure_public_id
    before_validation :ensure_customer_number
    before_validation :canonicalize_tax_id

    # Validations
    validates :public_id,       presence: true, uniqueness: true
    validates :customer_number, presence: true, uniqueness: true

    # Display helpers
    def display_name
      if person
        [ person.first_name, person.middle_name, person.last_name, person.name_suffix ]
          .compact_blank
          .join(" ")
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

    private

    def ensure_public_id
      self.public_id = SecureRandom.uuid if public_id.blank?
    end

    def ensure_customer_number
      return if customer_number.present?

      # try service up to 5 times
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

      # fallback if service failed
      loop do
        fallback = "C#{Time.current.strftime('%y%m%d')}#{format('%06d', SecureRandom.random_number(1_000_000))}"
        break(self.customer_number = fallback) unless self.class.exists?(customer_number: fallback)
      end
    end

    def canonicalize_tax_id
      self.tax_id = tax_id.to_s.gsub(/\D/, "") if tax_id.present?
    end
  end
end
