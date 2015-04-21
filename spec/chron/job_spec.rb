require 'spec_helper'

describe Chron::Job do
  describe '.perform' do
    it 'iterates Observable objects, scheduling polling jobs along the way' do
      expect(Chron::Observable::Job).to receive(:perform_later).with('Auction')
      expect(Chron::Observable::Job).to receive(:perform_later).with('Puppy')
      Chron::Job.perform_now
    end
  end
end
