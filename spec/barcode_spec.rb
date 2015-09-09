require 'spec_helper'

describe BankSlip::Barcode do
  context '.decode' do
    subject { described_class.decode("8#{segment}6700000656214#{code_and_date}00000000000010") }
    context 'when the segment is City Hall' do
      let(:segment) { 1 }
      let(:code_and_date) { '444420100310000' }

      it { expect(subject.product).to eq '8' }
      it { expect(subject.segment).to eq '1' }
      it { expect(subject.value_indentification).to eq '6' }
      it { expect(subject.verification_digit).to eq '7' }
      it { expect(subject.value).to eq 656214 }
      it { expect(subject.identification_code).to eq '4444'}
      it { expect(subject.payment_date).to eq Date.new(2010,03,10)}
      it { expect(subject.document_number).to eq 10 }
    end

    context 'when is a segment 6' do
      let(:segment) { 6 }
      let(:code_and_date) { '666620100310000' }

      it { expect(subject.segment).to eq '6' }
      it { expect(subject.identification_code).to eq '6666' }
    end

    context 'when the segment is Traffic Fine' do
      let(:segment) { 7 }
      let(:code_and_date) { '777777772010031' }

      it { expect(subject.segment).to eq '7' }
      it { expect(subject.identification_code).to eq '77777777' }
    end

    context "when the segment is 9" do
      let(:segment) { 9 }
      let(:code_and_date) { '999999992010031' }

      it { expect(subject.segment).to eq '9' }
      it { expect(subject.identification_code).to eq '99999999' }
    end
  end

  context '.to_typeable' do
    let(:barcode_data) { "81620000000010012342010031000000000000000010" }
    let(:typeable) { ["81620000000 7", "01001234201 9", "00310000000 3", "00000000010 9"] }

    subject { described_class.decode(barcode_data) }

    it { expect(subject.to_typeable).to eql typeable }
    it { expect(described_class.to_typeable(barcode_data)).to eql typeable }
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
      it { expect(subject.to_s).to eq "81620000000010012342010031000000000000000010" }
    end

    context "should correctly create segment 1 string for 8 digits identification code" do
      let(:segment) { '7' }
      let(:code) { '12345678' }

      it { expect(subject.to_s).to eql "87660000000010012345678201003100000000000010" }
    end
  end
end
