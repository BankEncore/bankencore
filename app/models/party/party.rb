# app/models/party/party.rb
module Party
  class Party < ApplicationRecord
    self.table_name = "parties"

    encrypts :tax_id, deterministic: true
    blind_index :tax_id, key: BlindIndex.master_key, encode: false

    has_one  :person,       class_name: "Party::Person",       inverse_of: :party, dependent: :destroy
    has_one  :organization, class_name: "Party::Organization", inverse_of: :party, dependent: :destroy
    has_many :emails,  class_name: "Party::Email",  inverse_of: :party, dependent: :destroy
    has_many :phones,  class_name: "Party::Phone",  inverse_of: :party, dependent: :destroy
    has_many :addresses, class_name: "Party::Address", inverse_of: :party, dependent: :destroy

    accepts_nested_attributes_for :person, :organization, :addresses, allow_destroy: true

    before_validation :ensure_public_id, :ensure_customer_number, on: :create

    validates :public_id,       presence: true, uniqueness: true, length: { is: 36 }
    validates :customer_number, presence: true, uniqueness: true, length: { is: 10 }
    validates :party_type,      presence: true, inclusion: { in: %w[person organization] }

    def tax_id=(val)
      return if val.blank?
      super(val)
      self.tax_id_masked = mask_tax_id(val) if has_attribute?(:tax_id_masked)
    end

    def tax_id_masked
      return self[:tax_id_masked] if has_attribute?(:tax_id_masked) && self[:tax_id_masked].present?
      mask_tax_id(tax_id)
    end

    def display_name
      case party_type
      when "organization"
        organization&.legal_name.presence
      when "person"
        [person&.first_name, person&.last_name].compact.join(" ").presence
      end || customer_number || public_id
    end

    def to_s
      display_name
    end

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
