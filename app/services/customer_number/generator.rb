# app/services/customer_number/generator.rb
module CustomerNumber
  class Generator
    class << self
      # Builds: 7-digit seq (zero-padded) + YY + Luhn check
      def call(now: Time.current)
        seq   = CustomerNumberCounter.next_value!
        base7 = format("%07d", seq)
        yy    = now.strftime("%y")
        body  = "#{base7}#{yy}"
        check = luhn_check_digit(body)
        "#{body}#{check}"
      end

      private

      def luhn_check_digit(num_str)
        raise ArgumentError, "digits only" unless num_str.match?(/\A\d+\z/)
        digits = num_str.chars.map { |c| c.ord - 48 } # '0' -> 0
        sum = 0
        digits.reverse.each_with_index do |d, i|
          if i.odd?        # double every second from the right
            d *= 2
            d -= 9 if d > 9
          end
          sum += d
        end
        (10 - (sum % 10)) % 10
      end
      private :luhn_check_digit
    end
  end
end
