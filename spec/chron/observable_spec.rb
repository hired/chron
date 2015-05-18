require 'spec_helper'
require 'chron/testing/helpers'

RSpec::Matchers.define :call_muppies do
  match do |block|
    expect_any_instance_of(Auction).to receive(:muppies!)
    block.call
    true
  end

  match_when_negated do |block|
    expect_any_instance_of(Auction).to_not receive(:muppies!)
    block.call
    true
  end
end

describe Chron::Observable do

  describe 'collecting Observables' do
    it 'appends class to Chron.observables upon inclusion' do
      expect(Chron::OBSERVABLES.keys).to include('Auction')
      expect(Chron::OBSERVABLES.keys).to include('Puppy')
    end
  end

  describe 'matchers' do
    let(:auction) { Auction.new }
    subject { auction }
    before { allow_any_instance_of(Auction).to receive(:puppies!) }

    describe_chron_observation_block_for :auction, :start_at do
      it { is_expected.to_not call_muppies}

      describe 'when auction name is Muppies' do
        let(:auction) { Auction.new(name: 'Muppies') }
        it { is_expected.to call_muppies }
      end
    end
  end
end
