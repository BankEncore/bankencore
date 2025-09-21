class RefEmailType < ApplicationRecord
  self.primary_key = "code"

  has_many :party_emails, class_name: "Party::Email", foreign_key: "email_type_code", primary_key: "code"

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end
