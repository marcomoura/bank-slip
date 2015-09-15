module BankSlip
  class Decorator

    # def initialize(options)
    #   @stub = stub
    # end
    # BankSlip::Decorator.data
    def self.data
      {
        header:{
          title:    'PREFEITURA MUNICIPAL DE MACAPÁ',
          subtitle: 'SECRETARIA MUNICIPAL DE FINANÇAS - SEMFI
                     DEPARTAMENTO DE RECEITA E ARRECADAÇÃO
                     Av. Procópio Rola, No 166 - CENTRO',
          document: 'Documento de Arrecadação Municipal (DAM)',
          logo:  nil
        },
        stub: {
          document_number:  '00171',
          payment_date: Date.today,
          total: 4200,

          due_date: Date.today,
          emission_date: Date.today,
          value:  4200,
          fine_and_interest: 0,
          adjustment: 0,
          discounts: 0,
          transaction_fee: nil,
          :revenue_description => 'DES-IF',
          :other_information   => nil,
          :authorized_agents => []
        },
        taxpayer: {
          official_name:  'BANCO DO BRASIL S/A',
          city_registration: '00000002786',
          cpf_cnpj: '00000002786',
        }
      }
    end

    def old
      {
        header:{
          :title    => "Prefeitura Municipal de #{@stub.city_hall.city.name}",
          :subtitle => Setting.get(@stub.city_hall, :nfe_header, :municipal_entity_name),
          :document => 'DAM - Documento de Arrecadação Municipal',
          logo:  nil
        },
        bank_slip: {
          :due_date            => @stub.payment_date,
          :payment_date        => @stub.payment_date,
          :value               => @stub.iss_value_cents,
          :fine_and_interest   => (@stub.fine_value_cents + @stub.interest_value_cents),
          :adjustment          => @stub.monetary_adjustment_cents,
          :discounts           => (@stub.discount_cents + @stub.specific_discount_cents),
          :transaction_fee     => @stub.transaction_fee_cents,
          :total               => @stub.total_value_cents,
          :document_number     => @stub.formatted_document_number,
          :emission_date       => @stub.emission_date.strftime('%d/%m/%Y'),
          :authorized_agents => @stub.city_hall.authorized_agents
        },
        other: {
          :official_name       => @stub.taxpayer.official_name,
          :cpf_cnpj            => @stub.taxpayer.cpf_cnpj,
          :city_registration   => @stub.taxpayer.city_registration,
          :incidence           => @stub.installment? ? @stub.incidence.year : @stub.incidence.strftime('%b / %Y').upcase,
          :revenue_description => 'DES-IF',
          :other_information   => @stub.other_information
        },
        barcode: {
          :string  => @stub.barcode_data,
          :code => @stub.barcode_typeable
        }
      }
    end
  end
end

# @city_hall = @stub.city_hall
# data = {
#   # HEADER DATA
#   :title    => "Prefeitura Municipal de #{@city_hall.city.name}",
#   :subtitle => Setting.get(@city_hall, :nfe_header, :municipal_entity_name),
#   :document => "DAM - Documento de Arrecadação Municipal",

#   # VALUES DATA
#   :due_date            => l(@stub.payment_date, :format => :default),
#   :payment_date        => l(@stub.payment_date, :format => :default),
#   :value               => cents_to_real(@stub.iss_value_cents, ''),
#   :fine_and_interest   => cents_to_real(@stub.fine_value_cents + @stub.interest_value_cents, ''),
#   :adjustment          => cents_to_real(@stub.monetary_adjustment_cents, ""),
#   :discounts           => cents_to_real(@stub.discount_cents + @stub.specific_discount_cents, ""),
#   :transaction_fee     => cents_to_real(@stub.transaction_fee_cents, ""),
#   :total               => cents_to_real(@stub.total_value_cents, ''),

#   # TAXPAYER DATA
#   :official_name       => @stub.taxpayer.official_name,
#   :cpf_cnpj            => format_cpf_cnpj(@stub.taxpayer.cpf_cnpj),
#   :city_registration   => @stub.taxpayer.city_registration,
#   :incidence           => @stub.installment? ? @stub.incidence.year : @stub.incidence.strftime('%b / %Y').upcase,
#   :emission_date       => @stub.emission_date.strftime('%d/%m/%Y'),
#   :document_number     => @stub.formatted_document_number,
#   :revenue_description => 'ISSQN-NF Eletrônica',
#   :other_information   => @stub.other_information,

#   # BARCODE DATA
#   :barcode_data     => @stub.barcode_data,
#   :barcode_typeable => @stub.barcode_typeable,

#   # INFO DATA
#   :authorized_agents => @city_hall.authorized_agents.to_s.upcase
# }


