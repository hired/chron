require 'spec_helper'

describe Chron::Observable::RecordJob do
  let(:auction) { Auction.create(start_at: Time.current) }
  let(:puppy) { Puppy.create(play_at: Time.current) }

  describe 'perform' do
    it 'calls provided ruby blocks for a given instance' do
      expect_any_instance_of(Auction).to receive(:puppies!)
      Chron::Observable::RecordJob.perform_now('Auction', :start_at, auction.id)
    end

    it 'sets observed_at value to prevent duplicate ' do
      Timecop.freeze do
        expect {
          Chron::Observable::RecordJob.perform_now('Puppy', :play_at, puppy.id)
        }.to change { puppy.reload.play_at__observation_completed_at}.from(nil).to(Time.current)
      end
    end
  end
end
