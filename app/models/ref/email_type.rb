module Ref
  class EmailType < ApplicationRecord
    self.table_name  = "ref_email_types"
    self.primary_key = "code"

    has_many :emails,
      class_name: "Party::Email",
      foreign_key: :email_type_code,
      primary_key: :code,
      inverse_of: :email_type,
      dependent: :restrict_with_error

    validates :code, presence: true
    validates :name, presence: true
  end
end
