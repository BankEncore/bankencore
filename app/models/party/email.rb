module Party
  class Email < ApplicationRecord
    self.table_name = "party_emails"

    encrypts :email, deterministic: true, downcase: true

    blind_index :email,
      key: BlindIndex.master_key,
      expression: ->(v) { v.to_s.downcase },
      encode: false  # store raw 32 bytes in BINARY(32)

    belongs_to :party, class_name: "Party::Party"
    belongs_to :email_type, class_name: "RefEmailType",
               foreign_key: :email_type_code, primary_key: :code
  end
end
