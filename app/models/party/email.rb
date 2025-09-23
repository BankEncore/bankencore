# frozen_string_literal: true
module Party
  class Email < ApplicationRecord
    include SinglePrimary 
    self.table_name = "party_emails"

    belongs_to :party, class_name: "Party::Party", inverse_of: :emails
    belongs_to :email_type, class_name: "Ref::EmailType",
      foreign_key: :email_type_code, primary_key: :code, optional: true

    # Encryption + blind index
    encrypts :email, deterministic: true
    blind_index :email,
      key: BlindIndex.master_key,
      encode: false,
      expression: ->(v) { v.to_s.strip.downcase }  # column is email_bidx by default

    # Normalize
    before_validation { self.email = email.to_s.strip.downcase.presence }

    # If the blind index is missing (legacy rows), force recompute
    before_validation :ensure_email_bidx

    validates :email,
      presence: true,
      format: { with: /\A[^@\s]+@[^@\s]+\z/ },
      if: -> { new_record? || will_save_change_to_email? }

    validates :party_id, uniqueness: { scope: :email_bidx }

    validate :only_one_primary, if: -> { is_primary? }
    before_save :set_domain_and_masked

    def masked
      return email_masked if email_masked.present?
      self.class.mask(email)
    end

    def self.mask(raw)
      local, dom = raw.to_s.split("@", 2)
      return raw if local.blank? || dom.blank?
      first = local[0]
      last  = local[-1]
      stars = "*" * [local.length - 2, 0].max
      "#{first}#{stars}#{last}@#{dom}"
    end

    private

    def ensure_email_bidx
      # If we have an email but no blind index, reassign to trigger blind_index callback.
      if email.present? && email_bidx.nil?
        self.email = email
      end
    end

    def set_domain_and_masked
      return if email.blank?
      _local, d = email.split("@", 2)
      self.domain       = d
      self.email_masked = self.class.mask(email)
    end

    def only_one_primary
      sibling = party&.emails&.where(is_primary: true)&.where.not(id: id)&.exists?
      errors.add(:is_primary, "already have a primary email") if sibling
    end
  end
end
