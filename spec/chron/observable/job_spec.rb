require 'spec_helper'

describe Chron::Observable::Job do
  describe 'perform' do
    describe 'triggering individual record jobs' do
      let!(:auction) { Auction.create(start_at: Time.current - 10.minutes) }
      let!(:auction2) { Auction.create(start_at: Time.current) }
      let!(:auction3) { Auction.create(start_at: Time.current + 10.minutes) }

      after do
        Auction.delete_all
      end

      let(:auctions) { Auction.where('start_at < ?', Time.current) }

      it 'fires jobs for each instance within ' do
        auctions.each do |auction|
          expect(Chron::Observable::RecordJob).to receive(:perform_later).with('Auction', 'start_at', auction.id)
        end

        Chron::Observable::Job.perform_now('Auction')
        expect(auction3.reload.start_at__observation_started_at).to be_nil
      end

      describe 'preventing separate polling jobs from colliding when queue size is large' do

        it 'only schedules new RecordJobs for records that have not previously started an observation' do
          auctions.update_all start_at__observation_started_at: Time.current
          expect(Chron::Observable::RecordJob).to_not receive(:perform_later)

          Chron::Observable::Job.perform_now('Auction')
        end

        it 'sets observation_started_at value so future pollers skip' do
          expect(Chron::Observable::RecordJob).to receive(:perform_later).at_least(1)

          Timecop.freeze do
            expect {
              Chron::Observable::Job.perform_now('Auction')
            }.to change { auctions.first.reload.start_at__observation_started_at}.from(nil).to(Time.current)
          end
        end
      end
    end
  end
end
