require 'spec_helper'

describe BankSlip::CheckDigit do
  context ".calc" do
    subject { described_class.new(number: number) }

    context 'when the result is 1' do
      let(:number) { '8220000215048200974123220154098290108605940' }
      it { expect(subject.calc).to eq 1 }
    end

    context 'when the result is 7' do
      let(:number) { '8160000065621424772015051502012002288364001' }
      it { expect(subject.calc).to eq 7 }
    end

    context 'when the result is 3' do
      let(:number) { '01230067896' }
      it { expect(subject.calc).to eq 3 }
    end
  end
end
