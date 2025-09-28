# app/services/phone_normalizer.rb
# frozen_string_literal: true

class PhoneNormalizer
  class << self
    # returns { e164: "+15555551234", raw: "555-555-1234", alpha2: "US", ext: "123" }
    def normalize(raw:, alpha2:, ext: nil)
      a2 = alpha2.to_s.upcase.presence || "US"
      r  = raw.to_s

      e164 = parse_with_phonelib(r, a2) || fallback_e164(r, a2)
      { e164: e164, raw: r, alpha2: a2, ext: ext.presence }
    end

    private

    def parse_with_phonelib(raw, alpha2)
      Phonelib.default_country = alpha2
      p = Phonelib.parse(raw, alpha2)
      return p.e164 if p&.valid?
      nil
    end

    # Minimal fallback using Ref::Country.calling_code and trunk-0 strip
    def fallback_e164(raw, alpha2)
      digits = raw.gsub(/[^\d+]/, "")
      return "+#{digits.delete_prefix('+')}" if digits.start_with?("+")

      cc = calling_code_for(alpha2)
      national = digits.sub(/^0+/, "") # drop trunk 0 (FR/GB/etc.)
      "+#{cc}#{national}"
    end

    def calling_code_for(alpha2)
      if defined?(Ref::Country) && Ref::Country.column_names.include?("calling_code")
        Ref::Country.find_by(code: alpha2)&.calling_code.to_s.presence || default_cc(alpha2)
      else
        default_cc(alpha2)
      end
    end

    def default_cc(alpha2)
      { "US"=>"1", "CA"=>"1", "FR"=>"33", "GB"=>"44", "DE"=>"49", "AU"=>"61", "NZ"=>"64", "IN"=>"91" }[alpha2] || "1"
    end
  end
end
