require 'spec_helper'
require "pdf/inspector"

describe BankSlip::Pdf do
  describe '.generate' do
    let(:data) do
      {
        header:{
          title:    'PREFEITURA MUNICIPAL DE MACAPA',
          subtitle: 'SECRETARIA MUNICIPAL DE FINANCAS - SEMFI',
          document: 'Documento de Arrecadacao Municipal (DAM)',
          logo:  nil
        },
        stub: {
          segment: '1',
          total: 656214,
          identification_code: '00666',
          due_date: '15/05/2015',
          payment_date: Date.today,
          emission_date: '05/05/2015',
          value:  4200,
          fine_and_interest: 0,
          adjustment: 0,
          discounts: 0,
          transaction_fee: 0,
          document_number: '00171',
          revenue_description: 'DES-IF',
          other_information: nil,
          authorized_agents: nil
        },
        payer: {
          official_name:  'BANCO DO BRASIL S/A',
          city_registration: '00000002786',
          cpf_cnpj: '00000002786',
        }
      }
    end

    subject { PDF::Inspector::Text.analyze(described_class.render(data)).strings }

    it { is_expected.to include(data[:header][:title]) }
    it { is_expected.to include(data[:header][:subtitle]) }
    it { is_expected.to include(data[:header][:document]) }
    it { is_expected.to include('Documento de Arrecadacao Municipal (DAM)') }
    it { is_expected.to include('VIA CONTRIBUINTE') }
    it { is_expected.to include('VIA BANCO') }
  end
end
