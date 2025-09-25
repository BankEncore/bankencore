# app/models/party/party.rb
module Party
  class Party < ApplicationRecord
    self.table_name = "parties"

    encrypts :tax_id, deterministic: true
    blind_index :tax_id, key: BlindIndex.master_key, encode: false

    has_one  :person,       class_name: "Party::Person",       inverse_of: :party, dependent: :destroy
    has_one  :organization, class_name: "Party::Organization", inverse_of: :party, dependent: :destroy
    has_many :addresses,    class_name: "Party::Address",      inverse_of: :party, dependent: :destroy
    has_many :emails,       class_name: "Party::Email",        inverse_of: :party, dependent: :destroy
    has_many :phones,       class_name: "Party::Phone",        inverse_of: :party, dependent: :destroy

    accepts_nested_attributes_for :person, allow_destroy: true
    accepts_nested_attributes_for :organization, allow_destroy: true
    accepts_nested_attributes_for :addresses, allow_destroy: true, reject_if: ->(h) {
      %i[line1 line2 line3 locality region_code postal_code country_code].all? { |k| h[k].to_s.strip.blank? }
    }
    accepts_nested_attributes_for :emails,  allow_destroy: true, reject_if: ->(h) { h["email"].to_s.strip.blank? }
    accepts_nested_attributes_for :phones,  allow_destroy: true, reject_if: ->(h) {
      h['id'].blank? && h['number_raw'].to_s.strip.blank? && h['phone_e164'].to_s.strip.blank? && h['phone_ext'].to_s.strip.blank?
    }

    before_validation :ensure_public_id,       on: :create
    before_validation :ensure_customer_number, on: :create
    before_validation :ensure_customer_number, on: :update, if: -> { customer_number.blank? }

    validates :public_id,        presence: true, uniqueness: true
    validates :customer_number,  presence: true, uniqueness: true

    def display_name
      if person
        [person.first_name, person.middle_name, person.last_name, person.name_suffix].compact_blank.join(" ")
      elsif organization
        organization.legal_name.to_s
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
      self.public_id ||= SecureRandom.uuid
    end

    def ensure_customer_number
      return if customer_number.present?
      5.times do
        self.customer_number = CustomerNumber::Generator.call
        break if self.class.where(customer_number: customer_number).none?
      end
    end
  end
end
