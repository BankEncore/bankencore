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

    # Nested attributes (server round-trip “Add …” flow)
    accepts_nested_attributes_for :person, allow_destroy: true
    accepts_nested_attributes_for :organization, allow_destroy: true

    accepts_nested_attributes_for :addresses, allow_destroy: true, reject_if: ->(h) {
      %i[line1 line2 line3 locality region_code postal_code country_code].all? { |k| h[k].to_s.strip.blank? }
    }

    accepts_nested_attributes_for :emails, allow_destroy: true, reject_if: ->(h) {
      h["email"].to_s.strip.blank?
    }

    accepts_nested_attributes_for :phones, allow_destroy: true, reject_if: ->(h) {
      h['id'].blank? &&                 # only reject brand-new rows
      h['number_raw'].to_s.strip.blank? &&
      h['phone_e164'].to_s.strip.blank? &&
      h['phone_ext'].to_s.strip.blank?
    }

    # Optional: convenience helpers for display (safe on nils)
    def display_name
      if person
        [person.first_name, person.middle_name, person.last_name, person.name_suffix].compact_blank.join(" ")
      elsif organization
        organization.legal_name.to_s
      else
        "(Unnamed Party)"
      end
    end

    def primary_email
      emails.find { |e| e.is_primary? } || emails.first
    end

    def primary_address
      addresses.find { |a| a.is_primary? } || addresses.first
    end

    def primary_phone
      phones.first
    end
  end
end
