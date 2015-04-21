require 'spec_helper'

describe Chron::Observable::RecordJob do
  let(:auction) { Auction.create(start_at: Time.current) }

  describe 'perform' do
    it 'calls provided ruby blocks for a given instance' do
      expect_any_instance_of(Auction).to receive(:puppies!)
      Chron::Observable::RecordJob.perform_now('Auction', :start_at, auction.id)
    end
  end
end
