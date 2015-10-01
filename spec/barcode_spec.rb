require 'spec_helper'

describe BankSlip::Barcode do
  context '.digits' do
    subject { described_class.new(options) }

    let(:options) do
      {value: 10000000001,
       identification_code: code,
       payment_date: Date.new(2010, 3, 10)}
    end

    context "should correctly create segment 1 string for 4 digits identification code" do
      let(:code) { '1234' }
      before { options.merge!(free_digits: '444') }
      it { expect(subject.digits).to eq "81621000000000112342010031000000000000000444" }
    end

    context "should correctly create segment 7 string for 8 digits identification code" do
      before { options.merge!(segment: 7) }
      let(:code) { 12345678 }

      it { expect(subject.digits).to eq "87661000000000112345678201003100000000000000" }
    end
  end

  context '.numerical_representation' do
    subject do
      described_class.new(value: 10000000001, identification_code: 4444,
                          payment_date: Date.new(2015, 12, 30), free_digits: 171)
    end
    let(:typeable) { ["81611000000 6", "00014444201 9", "51230000000 1", "00000000171 9"] }

    it { expect(subject.numerical_representation).to eq typeable }
  end
end
