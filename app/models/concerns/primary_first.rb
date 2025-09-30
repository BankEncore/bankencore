# frozen_string_literal: true

module PrimaryFirst
  extend ActiveSupport::Concern

  included do
    # Orders primary items first, then oldest first.
    scope :primary_first, -> {
      order(Arel.sql("#{table_name}.is_primary DESC, #{table_name}.created_at ASC"))
    }
  end
end
