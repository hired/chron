require 'spec_helper'

describe Chron::Observable::Job do
  describe 'perform' do
    describe 'triggering individual record jobs' do
      before do
        5.times do |n|
          Auction.create(start_at: (Time.current - 15.minutes) + 5 * n.minutes)
        end
      end

      after do
        Auction.delete_all
      end

      let(:auctions) { Auction.where(start_at: Chron::POLLING_RANGE.call) }

      it 'fires jobs for each instance within ' do
        auctions.each do |auction|
          expect(Chron::Observable::RecordJob).to receive(:perform_later).with('Auction', 'start_at', auction.id)
        end

        Chron::Observable::Job.perform_now('Auction')
      end

      # this test explicitly covers a case where the DB-setup code for this suite
      # renders the first test to fail silently.
      it 'sanity test calls record jobs for some records' do
        expect(Chron::Observable::RecordJob).to receive(:perform_later).at_least(1)
        Chron::Observable::Job.perform_now('Auction')
      end
    end
  end
end
