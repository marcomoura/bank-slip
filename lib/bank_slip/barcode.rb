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
      def build(options)
        new.tap do |bc|
          bc.segment               = options[:segment].to_s if options.key?(:segment)
          bc.value                 = options[:value].to_s
          bc.identification_code   = options[:identification_code].to_s
          bc.document_number       = options[:document_number].to_s
          bc.payment_date          = options[:payment_date]
        end
      end

    end

    attr_accessor :document_number, :identification_code, :payment_date, :product,
      :segment, :value, :value_indentification, :verification_digit

    def initialize
      self.product               = '8'
      self.segment               = '1'
      self.value_indentification = '6'
    end

    def digits
      str.insert(3, digit(str).to_s)
    end

    def numerical_representation
      digits.scan(/\d{11}/).collect {|p| "#{p} #{digit(p)}" }
    end

    private

    def str
      [product, segment, value_indentification,
       leading_zeros(value), identification_code,
       payment_date.strftime('%Y%m%d'), mask_doc_num].join('')
    end

    def leading_zeros(n, length = 11)
      "%0#{length}d" % n
    end

    def mask_doc_num
      length = 21 - identification_length
      leading_zeros(document_number, length)
    end

    def digit(bar_code_number)
      d = BankSlip::CheckDigit.new(bar_code_number)
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
      %w{7 9}.include?(segment) ? 8 : 4
    end
  end
end
