require 'spec_helper'

describe BankSlip::Barcode do
  context '.to_typeable' do
    subject do
      described_class.build(value: 11111111111,
                            identification_code: 4444,
                            payment_date: Date.new(2015, 12, 30),
                            document_number: 171)
    end
    let(:barcode_data) { "86620000000010012342010031000000000000000010" }
    let(:typeable) { ["81671111111 1", "11114444201 4", "51230000000 1", "00000000171 9"] }


    it { expect(subject.numerical_representation).to eql typeable }
  end

  context '.build' do
    subject do
      described_class.build(segment: segment, value: value, identification_code: code,
                            payment_date: Date.new(2010, 3, 10), document_number: 10)
    end
    let(:segment) { '1' }
    let(:value) { 100 }
    let(:code) { '1234' }

    context "should correctly create segment 1 string for 4 digits identification code" do
      it { expect(subject.digits).to eq "81620000000010012342010031000000000000000010" }
    end

    context "should correctly create segment 1 string for 8 digits identification code" do
      let(:segment) { '7' }
      let(:code) { '12345678' }

      it { expect(subject.digits).to eql "87660000000010012345678201003100000000000010" }
    end
  end
end
