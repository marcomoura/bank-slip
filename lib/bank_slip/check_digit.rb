module BankSlip
  class CheckDigit
    def initialize(number)
      @number = number
    end

    def calc
      r = result
      r == 10 ? 0 : r
    end

    private

    def result
      result_string = ""
      @number.reverse.split("").each_with_index do |c, index|
        result_string << (c.to_i * ((1 + index) % 2 + 1)).to_s
      end

      10 - sum(result_string) % 10
    end

    def sum(result_string)
      total = 0
      result_string.each_char { |c| total += c.to_i }
      total
    end
  end
end

