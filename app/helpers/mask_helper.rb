# app/helpers/mask_helper.rb
module MaskHelper
  def mask_email(email)
    return "" if email.blank?
    name, domain = email.split("@", 2)
    "#{name[0]}***@#{domain}"
  end

  def mask_tax_id(value, id_type: nil)
    return "" if value.blank?

    digits = value.to_s.gsub(/\D/, "")
    last4  = digits[-4, 4] || digits

    case id_type.to_s
    when "ein"
      "••-••••#{last4}"
    when "ssn", ""
      "•••-••-#{last4}"  # default to SSN-style if unknown
    else
      "••••#{last4}"     # fallback if some other type
    end
  end
end
