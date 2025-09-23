module Party
  class Phone < ApplicationRecord
    include SinglePrimary
    self.table_name = "party_phones"

    belongs_to :party, class_name: "Party::Party", inverse_of: :phones
    belongs_to :phone_type, class_name: "Ref::PhoneType",
      foreign_key: :phone_type_code, primary_key: :code, optional: true

    # virtuals posted by the form
    attr_accessor :number_raw, :country_alpha2

    # show something in the form when editing
    def number_raw = @number_raw.presence || phone_e164
    def country_alpha2 = @country_alpha2.presence || "US"

    before_validation :normalize_phone!

    # validate only when user entered anything
    with_options if: :row_has_content? do
      validates :phone_e164, presence: true
      validates :phone_type_code, presence: true
    end

    private

    def row_has_content?
      number_raw.to_s.strip.present? || phone_ext.to_s.strip.present? || phone_type_code.to_s.strip.present?
    end

    def normalize_phone!
      raw = number_raw.to_s.strip
      return if raw.blank? # reject_if will drop empty rows

      # strip extension typed as "x123" or "ext 123"
      ext  = raw[/\b(?:ext\.?|x)\s*([0-9]{1,10})\b/i, 1]
      main = raw.sub(/\s*\b(?:ext\.?|x)\s*[0-9]{1,10}\b/i, "").strip

      region = main.start_with?("+") ? nil : country_alpha2
      parsed = Phonelib.parse(main, region)

      unless parsed.valid?
        errors.add(:number_raw, "is not a valid phone number")
        return
      end

      self.phone_e164 = parsed.e164
      self.phone_ext  = ext.presence || phone_ext.to_s.strip.presence
    end
  end
end
