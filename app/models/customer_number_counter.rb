# app/models/customer_number_counter.rb
class CustomerNumberCounter < ApplicationRecord
  # Returns next integer in [min_value..max_value] cycling, inside a row lock.
  def self.next_value!
    transaction do
      counter = lock(true).first || create!(current_value: 1000, min_value: 1001, max_value: 9_999_999)
      nxt = counter.current_value + 1
      nxt = counter.min_value if nxt > counter.max_value
      counter.update!(current_value: nxt)
      nxt
    end
  end
end
