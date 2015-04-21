require 'spec_helper'

describe Chron::Observable do

  describe 'collecting Observables' do
    it 'appends class to Chron.observables upon inclusion' do
      expect(Chron::OBSERVABLES.keys).to include('Auction')
      expect(Chron::OBSERVABLES.keys).to include('Puppy')
    end
  end
end
