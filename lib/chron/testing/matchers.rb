RSpec::Matchers.define :at_time do |column_name, observation_expectations|
  match do |observable|
    expect {
      observable.instance_eval &Chron.observation(observable.class.to_s, column_name)
    }.to observation_expectations.call
  end
end
