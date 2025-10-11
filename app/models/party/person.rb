module Party
  class Person < ApplicationRecord
    self.primary_key = "party_id"
    self.table_name = "party_people"

    enum :citizenship, { domestic: 0, foreign: 1 }

    belongs_to :party, class_name: "Party::Party", foreign_key: :party_id
    belongs_to :nationality_country,
      class_name: "Ref::Country",
      foreign_key: :nationality_country_code,
      primary_key: :code,
      optional: true
    belongs_to :residence_country,
      class_name: "Ref::Country",
      foreign_key: :residence_country_code,
      primary_key: :code,
      optional: false

    before_validation :apply_defaults_and_rules

    # optional validations:
    validates :first_name, presence: true
    validates :last_name, presence: true

    validates :residence_country_code, presence: true
    validates :nationality_country_code, presence: true, if: -> { foreign? }

    private
    def apply_defaults_and_rules
      self.residence_country_code ||= "US"
      if domestic?
        self.nationality_country_code = "US"
      end
    end
  end
end
