require "prawn"
require "prawn/measurement_extensions"

module BankSlip
  class Pdf
    include Prawn::View

    def self.render(data)
      new(data).create.render
    end

    def initialize(data)
      @data = data
      # Measures
      @vHEADER_HEIGHT      = 0.82.in
      @vBODY_HEIGHT        = 2.35.in
      @vINFO_WIDTH         = 6.15.in
      @vVALUES_WIDTH       = 7.65.in - @vINFO_WIDTH
      @vLINE_HEIGHT        = 0.335.in
      @vFOOTER_HEIGHT      = 4.25.in - @vHEADER_HEIGHT - @vBODY_HEIGHT
      @vFOOTER_LEFT_WIDTH  = 2.5.in
    end

    def create
      content(0, 'CONTRIBUINTE')
      footer_payer
      cut_line
      content(5.3.in, 'BANCO')
      footer_payeer
      add_barcode
      self
    end

    private

    def border
      stroke_color '999999'
      line_width 1
      stroke_bounds
    end

    def add_digit(numbers, left_padding = 0)
      bounding_box([0.185.in + left_padding, 0.85.in], width: 1.05.in, height: 0.17.in) do
        move_down 0.03.in
        stroke_color '444444'
        stroke_bounds
        text numbers, size: 9, style: :bold, align: :center
      end
    end

    def copy_for(caption)
      bounding_box [bounds.left - 0.05.in, bounds.top_left[1] - 0.7.in], width: bounds.right, height: 0.82.in do
        text "VIA #{caption}", size: 7, style: :normal, align: :right
      end
    end

    def content(initial_y, caption)
      bounding_box [0, bounds.top_left()[1] - initial_y], width: 7.65.in, height: 3.17.in do
        border
        header_content
        copy_for(caption)

        # Info to the left
        bounding_box([0.in, bounds.top_left[1] - @vHEADER_HEIGHT], width: @vINFO_WIDTH, height: @vBODY_HEIGHT) do
          stroke do
            stroke_color 'AAAAAA'
            line bounds.bottom_left, bounds.bottom_right
          end

          draw_line("Nome Oficial"        , @data[:payer][:official_name]      , @vINFO_WIDTH   , @vLINE_HEIGHT , 0 , 0  , 'E6E6E6')
          draw_line("CPF/CNPJ"            , @data[:payer][:cpf_cnpj]           , @vINFO_WIDTH/4 , @vLINE_HEIGHT , 0 , 1)
          draw_line("Inscrição Municipal" , @data[:payer][:city_registration]  , @vINFO_WIDTH/4 , @vLINE_HEIGHT , 1 , 1)
          draw_line("Emissão"             , @data[:stub][:emission_date]       , @vINFO_WIDTH/4 , @vLINE_HEIGHT , 2 , 1  , 'E6E6E6')
          draw_line("Incidência"          , @data[:stub][:incidence]           , @vINFO_WIDTH/4 , @vLINE_HEIGHT , 3 , 1  , 'E6E6E6')
          draw_line("Receita"             , @data[:stub][:revenue_description] , @vINFO_WIDTH   , @vLINE_HEIGHT , 0 , 2)

          move_down 0.1.in
          indent(0.1.in) do
            text 'Outras Informações', size: 8
            text @data[:stub][:other_information]
          end

          text_box "PAGÁVEL EM QUALQUER AGENTE ARRECADADOR AUTORIZADO ATÉ #{@data[:stub][:expiration_date][:string]}.\n" +
                    "O VALOR PARA PAGAMENTO DESTE DOCUMENTO NÃO PODE SER ATUALIZADO. ",
                     at: [bounds.bottom_left[0] + 0.075.in, bounds.bottom_left[0] + 0.8.in],
                     height: 0.75.in,
                     size: 8,
                     style: :normal,
                     valign: :bottom

        end # Info to the left

        # Values to the right
        bounding_box([@vINFO_WIDTH, bounds.top_left[1] - @vHEADER_HEIGHT], width: @vVALUES_WIDTH, height: @vBODY_HEIGHT) do
          # Bottom line
          stroke do
            stroke_color 'AAAAAA'
            line bounds.bottom_left, bounds.bottom_right
            line bounds.top_left, bounds.bottom_left
          end

          draw_line("Vencimento da Guia"      , @data[:stub][:expiration_date][:string]          , @vVALUES_WIDTH , @vLINE_HEIGHT , 0 , 0 , 'E6E6E6' , :right)
          draw_line("Valor (R$)"              , @data[:stub][:value]             , @vVALUES_WIDTH , @vLINE_HEIGHT , 0 , 1 , 'FFFFFF' , :right)
          draw_line("Multa/Juros (R$)"        , @data[:stub][:fine_and_interest] , @vVALUES_WIDTH , @vLINE_HEIGHT , 0 , 2 , 'FFFFFF' , :right)
          draw_line("Outros Acréscimos (R$)"  , @data[:stub][:adjustment]        , @vVALUES_WIDTH , @vLINE_HEIGHT , 0 , 3 , 'FFFFFF' , :right)
          draw_line("Descontos (R$)"          , "-#{@data[:stub][:discounts]}"   , @vVALUES_WIDTH , @vLINE_HEIGHT , 0 , 4 , 'FFFFFF' , :right)
          draw_line("Taxa de Expediente (R$)" , @data[:stub][:transaction_fee]   , @vVALUES_WIDTH , @vLINE_HEIGHT , 0 , 5 , 'FFFFFF' , :right)
          draw_line("Total (R$)"              , @data[:stub][:total][:string]    , @vVALUES_WIDTH , @vLINE_HEIGHT , 0 , 6 , 'E6E6E6' , :right  , '000000')
        end # Values to the right
      end
    end

    def footer_payer
      move_down 0.1.in
      text "Documento No. #{@data[:stub][:document_number]}", size: 8
      bounding_box([0, bounds.top_left[1] - 0.4.in - @vHEADER_HEIGHT - @vBODY_HEIGHT],
                   width: 194.mm, height: 22.mm) do

        move_down 0.05.in
        indent 0.05.in do
          text 'AUTENTICAÇÃO MECÂNICA', size: 7, align: :left
        end

        stroke do
          stroke_color '999999'
          line bounds.top_left, bounds.top_right
          line bounds.top_left, bounds.bottom_left
        end
      end
    end

    def footer_payeer
      move_down 0.1.in
      text "Documento No. #{@data[:stub][:document_number]}", size: 8
      bounding_box([bounds.right - 2.55.in, bounds.bottom_left[1] + 0.7.in],
                   width: 65.mm, height: 22.mm) do

        move_down 0.05.in
        indent 0.03.in do
          text 'AUTENTICAÇÃO MECÂNICA', size: 7, align: :center
        end

        stroke do
          stroke_color '999999'
          line bounds.top_left, bounds.top_right
          line [bounds.top_left, 0], [bounds.top_left[0]+50, 0]
        end
      end
    end

    def draw_line(label, value, width, height, column = 0, line = 0, bg_color = 'FFFFFF', align = :left, stroke = 'AAAAAA')
      bounding_box([0.in + column * width, bounds.top_left[1] - line * height], width: width, height: height) do
        if bg_color != 'FFFFFF'
          fill_color bg_color
          transparent(0.6) do
            fill_rectangle [bounds.top_left[0] + 1, bounds.top_left[1] - 1], width, height
          end
          fill_color '000000'
        end

        draw_line_text(label, value, width, height, align)
        stroke_color stroke
        line_width 1
        stroke_bounds
      end
    end

    def draw_line_text(label, value, width, height, align)
      bounding_box([bounds.top_left[0], bounds.top_left[1] - 0.05.in], width: width - 0.075.in, height: height - 0.05.in) do
        indent(0.075.in) do
          text label, size: 7, style: :normal, leading: 0.025.in
          text value.to_s, size: 8, style: :bold, align: align
        end
      end
    end

    def header_content
      bounding_box [0,bounds.top_left()[1]], width: 7.65.in, height: @vHEADER_HEIGHT do
        stroke do
          stroke_color 'AAAAAA'
          line bounds.bottom_left, bounds.bottom_right
        end
        indent 0.1.in do
          unless @data[:header][:logo].nil?
            img = image @data[:header][:logo], fit: [0.71.in, 0.68.in], position: :left, vposition: :center
            image_width = img.scaled_width + 0.15.in
            move_up img.scaled_height - 0.15.in
          else
            image_width = 0
            move_down 0.2.in
          end
          indent image_width do
            text @data[:header][:title]   , size: 10 , style: :bold  , leading: -0.01.in
            text @data[:header][:subtitle], size: 8  , style: :normal, leading:  0.02.in
            move_down 0.05.in
            text @data[:header][:document], size:  13, style: :bold
          end
        end
      end
    end

    def cut_line
      dash 3
      stroke_line [bounds.left, 5.3.in, bounds.right + 0.1.in, 5.3.in]
      undash
      font 'ZapfDingbats' do
        text_box "#", size: 18, rotate: 180, at: [bounds.right, 5.3.in + 0.13.in]
      end
    end

    def add_barcode
      bounding_box([-13, 65],
                   width: 7.65.in - @vFOOTER_LEFT_WIDTH,
                   height: @vFOOTER_HEIGHT) do
        add_digit(barcode.numerical_representation[0])
        add_digit(barcode.numerical_representation[1], 1.242.in)
        add_digit(barcode.numerical_representation[2], (1.242.in * 2))
        add_digit(barcode.numerical_representation[3], (1.242.in * 3))
      end
      add_bar
    end

    def add_bar
      Barby::Code25Interleaved.new(barcode.digits)
        .annotate_pdf(self, x: 0, y: -10, xdim: 0.85, height: 0.5.in)
    end

    def barcode
      @_barcode ||= BankSlip::Barcode
                      .new(segment:             @data[:stub][:segment],
                           value:               @data[:stub][:total][:integer],
                           identification_code: @data[:stub][:identification_code],
                           payment_date:        @data[:stub][:expiration_date][:date],
                           free_digits:         @data[:stub][:free_digits])
    end
  end
end
