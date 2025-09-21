module Party
  class Phone < ApplicationRecord
    self.table_name = "party_phones"

    belongs_to :party, class_name: "Party::Party", foreign_key: :party_id

    belongs_to :phone_type, class_name: "RefPhoneType",
               foreign_key: :phone_type_code, primary_key: :code

    validates :phone_e164, presence: true
  end
end
