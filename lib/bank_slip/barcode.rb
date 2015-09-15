# Barcode data according to febraban specification
# POSICAO | TAMANHO | CONTEUDO                                   |
# 01 – 01 | 1       | Identificacao do Produto                   | Fixo: 8
# 02 – 02 | 1       | Identificacao do Segmento                  | Fixo: 1 para prefeituras
# 03 – 03 | 1       | Identificacao do valor real ou referencia  | 6 e mod10 para DV ou 8 e mod11 para DV
# 04 – 04 | 1       | Dígito verificador geral (módulo 10 ou 11) | mod10 ou mod11
# 05 – 15 | 11      | Valor                                      | valor em reais

# 16 – 19 | 4       | Identificação da Empresa/Órgão  para segmento 1 | código de 4 digitos febraban
# 20 – 44 | 25      | Campo livre de utilização da Empresa/Órgão | AAAAMMDD + uso livre

# 16 – 23 | 8       | Identificação da Empresa/Órgão  para segmento 1 | código de 8 digitos banco (inicio CNPJ)
# 24 – 44 | 21      | Campo livre de utilização da Empresa/Órgão | AAAAMMDD + uso livre
#
require 'bank_slip/check_digit'
require 'barby'
require 'barby/barcode/code_25_interleaved'
require 'barby/outputter/prawn_outputter'

module BankSlip
  class Barcode
    class << self
      #builder
      def decode(line)
        parts = line.unpack(BankSlip::Barcode.seg_formatter(BankSlip::Barcode.identification_length(line[1])))
        bc = new
        if parts.size > 0
          bc.product               = parts[0]
          bc.segment               = parts[1]
          bc.value_indentification = parts[2]
          bc.verification_digit    = parts[3]
          bc.value                 = parts[4].to_i
          bc.identification_code   = parts[5]
          bc.payment_date          = Date.parse(parts[6]) rescue nil
          bc.document_number       = parts[7].to_i
        end
        return bc
      end


      # The Indentification code is defined by the segment
      # Use FEBRABAN code (4 digits) for the segments:
      #   1. Prefeituras;
      #   2. Saneamento;
      #   3. Energia Elétrica e Gás;
      #   4. Telecomunicações;
      #   5. Órgãos Governamentais;
      #   6. Carnes e Assemelhados ou demais
      #
      # Use CNPJ (8 digits) for the segments:
      #   7. Multas de transito
      #   9. Uso exclusivo do banco
      def identification_length(segment)
        %w{7 9}.include?(segment) ? 8 : 4
      end

      # Creates the string used for unpack
      def seg_formatter(code_length)
        "A1A1A1A1A11A#{code_length}A8A#{21-code_length}"
      end

      # stub.barcode_data
      def to_typeable(barcode_data)
        barcode_data.scan(/(\d{11})/).collect do |p|
          d = BankSlip::CheckDigit.new(p.to_s)

          p.join('') + ' ' + d.calc.to_s
        end
      end

      #builder
      def build(params)
        new.tap do |bc|
          bc.segment               = params[:segment].to_s
          bc.value                 = params[:value].to_s
          bc.identification_code   = params[:identification_code].to_s
          bc.payment_date          = params[:payment_date]
          bc.document_number       = params[:document_number].to_s
        end
      end
    end

    attr_accessor :document_number, :identification_code, :payment_date, :product,
                  :segment, :value, :value_indentification, :verification_digit

    def initialize
      self.product               = '8'
      self.value_indentification = '6'
    end

    #  stub.barcode_data = barcode.to_s
    # Gives the 44 chars long string
    def to_s
      str = ""
      str << product                                                       # product identification
      str << segment                                                       # segment identification
      str << value_indentification                                         # monetary identification
      str << "%011d" % self.value                                          # value
      str << identification_code                                           # identification code
      str << payment_date.strftime('%Y%m%d')                              # payment date
      str << "%0#{21-BankSlip::Barcode.identification_length(segment)}d" % document_number  # document number
      str.gsub!(/^(\d{3})(\d{40})$/, '\1' + check_digit(str).to_s + '\2')
      str
    end

    def to_typeable
      BankSlip::Barcode.to_typeable(to_s)
    end

    private

    def check_digit(bar_code_number)
      d = BankSlip::CheckDigit.new(bar_code_number)
      d.calc
    end
  end
end
