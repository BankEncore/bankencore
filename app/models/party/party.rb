# app/models/party/party.rb
module Party
  class Party < ApplicationRecord
    self.table_name = "parties"

    # Encryption / search
    encrypts :tax_id, deterministic: true
    blind_index :tax_id,
      key: BlindIndex.master_key,
      encode: false # column: tax_id_bidx

    # Associations
    has_one  :person,       class_name: "Party::Person",       inverse_of: :party, dependent: :destroy
    has_one  :organization, class_name: "Party::Organization", inverse_of: :party, dependent: :destroy
    has_many :phones,       class_name: "Party::Phone",        inverse_of: :party, dependent: :destroy
    has_many :addresses,    class_name: "Party::Address",      inverse_of: :party, dependent: :destroy
    has_many :emails,        class_name: "Party::Email",       inverse_of: :party, dependent: :destroy
    has_many :group_memberships, class_name: "Party::GroupMembership",
         inverse_of: :party, dependent: :destroy
    has_many :groups, through: :group_memberships, class_name: "Party::Group"

    has_many :outgoing_links, class_name: "Party::Link",
            foreign_key: :source_party_id, inverse_of: :source_party, dependent: :destroy
    has_many :incoming_links, class_name: "Party::Link",
            foreign_key: :target_party_id, inverse_of: :target_party, dependent: :destroy

    # Scopes    
    scope :people,        -> { where(party_type: "person") }
    scope :organizations, -> { where(party_type: "organization") }
    scope :by_public_id,  ->(pid) { where(public_id: pid) }
    scope :by_customer_number, ->(num) { where(customer_number: num) }

    accepts_nested_attributes_for :person, :organization, allow_destroy: true
    accepts_nested_attributes_for :emails,
      allow_destroy: true,
      reject_if: ->(h) { h['email'].to_s.strip.blank? && h['id'].blank? }
    accepts_nested_attributes_for :addresses, allow_destroy: true

    before_validation :ensure_public_id, :ensure_customer_number, on: :create

    validates :public_id,       presence: true, uniqueness: true, length: { is: 36 }
    validates :customer_number, presence: true, uniqueness: true, length: { is: 10 }
    validates :party_type,      presence: true, inclusion: { in: %w[person organization] }
    validates :tax_id,
      format: { with: /\A\d{9}\z/, message: "must be 9 digits" },
      allow_nil: true
    
    # Email helpers
    def primary_email
      emails.find { |e| e.is_primary? } || emails.first
    end

    def email_masked
      primary_email&.masked
    end

    # Address helpers
    def primary_address
      addresses.find { |a| a.is_primary? } || addresses.first
    end

    # Normalize and keep masked cache in sync
    def tax_id=(val)
      s = val.to_s.gsub(/\D/, "")
      super(s.presence) # nil if blank
      if has_attribute?(:tax_id_masked)
        self[:tax_id_masked] = mask_tax_id(s)
      end
    end

    def tax_id_masked
      return self[:tax_id_masked] if has_attribute?(:tax_id_masked) && self[:tax_id_masked].present?
      mask_tax_id(tax_id)
    end

    def display_name
      case party_type
      when "organization" then organization&.legal_name.presence
      when "person"       then [person&.first_name, person&.last_name].compact.join(" ").presence
      end || customer_number || public_id
    end
    def to_s = display_name

    def to_param = public_id

    private

    def ensure_public_id
      self.public_id ||= SecureRandom.uuid
    end

    def ensure_customer_number
      self.customer_number ||= CustomerNumber::Generator.call
    end

    def mask_tax_id(raw)
      s = raw.to_s.gsub(/\D/, "")
      return "" if s.blank?
      ("•" * [s.length - 4, 0].max) + s.last(4)
    end
  end
end
