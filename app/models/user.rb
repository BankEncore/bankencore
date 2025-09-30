class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def display_name
    parts = [ first_name, last_name ].compact_blank
    return parts.join(" ") if parts.any?
    (try(:email_address) || try(:email)).to_s
  end

  def login_email
  respond_to?(:email_address) ? email_address : (respond_to?(:email) ? email : nil)
  end
end
