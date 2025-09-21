module Party
  class Person < ApplicationRecord
    self.primary_key = "party_id"
    self.table_name = "party_people"

    belongs_to :party, class_name: "Party::Party", foreign_key: :party_id

    # optional validations:
    validates :first_name, presence: true
    validates :last_name, presence: true
  end
end
