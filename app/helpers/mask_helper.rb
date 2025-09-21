# app/helpers/mask_helper.rb
module MaskHelper
  def mask_email(email)
    return "" if email.blank?
    name, domain = email.split("@", 2)
    "#{name[0]}***@#{domain}"
  end

  def mask_tax_id(tax_id)
    return "" if tax_id.blank?
    # e.g., show last 4
    "•••-••-#{tax_id[-4..]}"
  end
end
