class RefPhoneType < ApplicationRecord
  self.primary_key = "code"

  has_many :party_phones, class_name: "Party::Phone", foreign_key: "phone_type_code", primary_key: "code"

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end
