# Barcode data according to febraban specification
#
# POSITION | SIZE | CONTENT                  |
# 01 – 01  | 1    | Product                  | Fixed: 8
# 02 – 02  | 1    | Segment                  | Fixed: 1 for City Halls
# 03 – 03  | 1    | Real or Reference value  | 6 and mod10 for DV or 8 and mod11 for DV
# 04 – 04  | 1    | Dígito verificador geral | mod10 or mod11
# 05 – 15  | 11   | Value                    | value in Reais

# 16 – 19  | 4    | Company or organization  | code of 4 digits febraban
# 20 – 44  | 25   | Free                     | AAAAMMDD + free use

# 16 – 23  | 8    | Company or organization  | code of 8 digits bank (start CNPJ)
# 24 – 44  | 21   | Free                     | AAAAMMDD + free use
#
#
require 'barby'
require 'barby/barcode/code_25_interleaved'
require 'barby/outputter/prawn_outputter'

module BankSlip
  class Barcode

    # > options = {value: 1, identification_code: 2, document_number: 10, payment_date: Date.new(2010, 3, 10)}
    # > barcode = BankSlip::Barcode.new(options)
    def initialize(value:, identification_code:, payment_date:,
                   segment: 1, effective_reference: 6,
                   free_digits: 0, product: 8)
      @value               = value
      @segment             = segment
      @identification_code = identification_code
      @payment_date        = payment_date
      @product             = product
      @effective_reference = effective_reference
      @free_digits         = free_digits
      fail "identification_code #{identification_code} too long, #{identification_length} characters is the maximum allowed, for the segment #{segment}"  unless valid_identification_code?
    end

    # > barcode.digits
    # => "81640000000000100022010031000000000000000010"
    def digits
      @digits ||= numbers.insert(3, digit(numbers).to_s)
    end

    # > barcode.numerical_representation
    # => ["81640000000 5", "00010002201 1", "00310000000 3", "00000000010 9"]
    def numerical_representation
      @numerical_representation ||= digits.scan(/\d{11}/).collect {|p| "#{p} #{digit(p)}" }
    end

    private

    def valid_identification_code?
      @identification_code.to_s.size.eql?(identification_length)
    end

    def numbers
      @numbers ||= [
        @product,
        @segment,
        @effective_reference,
        leading_zeros(@value),
        mask_id,
        @payment_date.strftime('%Y%m%d'),
        free_digits_leading_zeros
      ]
      .join('')
    end

    def leading_zeros(n, length = 11)
      "%0#{length}d" % n
    end

    def mask_id
      leading_zeros(@identification_code, identification_length)
    end

    def free_digits_leading_zeros
      length = 21 - identification_length
      leading_zeros(@free_digits, length)
    end

    def digit(code_number)
      d = BankSlip::CheckDigit.new(number: code_number)
      d.calc
    end

    # The Indentification code is defined by the segment
    # Use 4 digits (FEBRABAN code) for the segments:
    #   1. Prefeituras;
    #   2. Saneamento;
    #   3. Energia Elétrica e Gás;
    #   4. Telecomunicações;
    #   5. Órgãos Governamentais;
    #   6. Carnes e Assemelhados ou demais
    #
    # Use 8 digits (CNPJ) for the segments:
    #   7. Multas de transito
    #   9. Uso exclusivo do banco
    def identification_length
      %w{7 9}.include?(@segment.to_s) ? 8 : 4
    end
  end
end
