def describe_chron_observation_block_for(observable, column_name, &block)
  describe "observation blocks for #{observable}##{column_name}" do
    specify do
      expect(Chron.observation(send(observable).class.to_s, column_name)).to be_present
    end

    describe 'observation block' do
      subject { -> { Chron.execute_observation(send(observable), column_name)} }

      instance_eval &block
    end
  end
end
