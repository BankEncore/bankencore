# app/models/party/phone.rb
module Party
  class Phone < ApplicationRecord
    self.table_name = "party_phones"

    belongs_to :party, class_name: "Party::Party", inverse_of: :phones
    belongs_to :phone_type, class_name: "Ref::PhoneType",
               foreign_key: :phone_type_code, primary_key: :code, optional: true, inverse_of: :phones

    validates :number, presence: true
  end
end
