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
          logo:  "#{File.dirname(__FILE__)}/fixtures/logo.jpg"
        },
        stub: {
          segment: '1',
          expiration_date: {
            string: '25/01/2016',
            date: Date.new(2016, 1, 25)
          },
          emission_date: '25/05/2015',
          incidence: '04/2015',
          value:  '42,00',
          fine_and_interest: '1,00',
          adjustment: '1,55',
          discounts: '1,30',
          transaction_fee: '1,01',
          total: {
            string: '44,26',
            integer: 4426
          },
          document_number: '00171',
          identification_code: '4444',
          revenue_description: 'DES-IF',
          other_information: nil,
          authorized_agents: nil,
          free_digits: 00171
        },
        payer: {
          official_name:  'BANCO DO BRASIL S/A',
          city_registration: '00000002786',
          cpf_cnpj: '00000002786',
        }
      }
    end

    # let(:pdf) { described_class.new(data).create.render_file('test2.pdf') }
    let(:pdf) { described_class.render(data) }
    subject { PDF::Inspector::Text.analyze(pdf).strings }

    it { is_expected.to include(data[:header][:title]) }
    it { is_expected.to include(data[:header][:subtitle]) }
    it { is_expected.to include(data[:header][:document]) }
    it { is_expected.to include('Documento de Arrecadacao Municipal (DAM)') }
    it { is_expected.to include('VIA CONTRIBUINTE') }
    it { is_expected.to include('VIA BANCO') }
  end
end
