# app/models/ref/identifier_type.rb
module Ref
  class IdentifierType < ApplicationRecord
    self.table_name = "ref_identifier_types"

    has_many :identifiers,
      class_name: "::Party::Identifier",
      foreign_key: :identifier_type_id,
      inverse_of: :identifier_type

    validates :code, :name, presence: true
    validates :code, uniqueness: true
    validates :mask_rule,
      format: { with: /\A(?:last4|ssn|ein|none|pattern:\d+-\d+-\d+)\z/ },
      allow_blank: true
  end
end
