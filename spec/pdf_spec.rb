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
          expiration_date: '25/01/2016',
          emission_date: '25/05/2015',
          incidence: '04/2015',
          value:  '42,00',
          fine_and_interest: '1,00',
          adjustment: '1,55',
          discounts: '1,30',
          transaction_fee: '1,01',
          total: '9.876.543,21',
          document_number: '00171',
          identification_code: '4444',
          revenue_description: 'DES-IF',
          other_information: nil,
          authorized_agents: nil,
        },
        payer: {
          official_name:  'BANCO DO BRASIL S/A',
          city_registration: '00000002786',
          cpf_cnpj: '00000002786',
        },
        barcode: {
          payment_date: Date.new(2016, 1, 25),
          value: 987654321,
          identification_code: '4444',
          free_digits: '123456789',
          segment: 1
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
    it { is_expected.to include("8#{data[:barcode][:segment]}630098765 7") }
    it { is_expected.to include('43214444201 4') }
    it { is_expected.to include('60125000000 2') }
    it { is_expected.to include("00#{data[:barcode][:free_digits]} 7") }
  end
end
