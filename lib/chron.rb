require "active_job"
require "chron/version"

module Chron
  OBSERVABLES = {}

  def self.observable_resources
    OBSERVABLES.keys
  end

  def self.add_observable_resource(class_name)
    OBSERVABLES[class_name.to_s] = {}
  end

  def self.observations_for(class_name)
    observable = OBSERVABLES[class_name]
    raise UnknownObservable.new("#{class_name}") if observable.blank?
    observable.keys
  end

  def self.observation(class_name, column)
    observation = OBSERVABLES[class_name][column.to_sym]
    raise UnknownObservation.new("#{class_name} #{column}") if observation.blank?
    observation
  end

  def self.add_observation(class_name, column, block)
    observable = OBSERVABLES[class_name]
    raise ExistingObservation.new("#{class_name} #{column}") if observable[column.to_sym].present?
    observable[column.to_sym] = block
  end

  class ExistingObservation < StandardError; end
  class UnknownObservable < StandardError; end
  class UnknownObservation < StandardError
    def initialize(obj)
      super("Please declare #{obj} block in app/models/path-to-#{obj.underscore}.rb")
    end
  end
  class UnregisteredObservable < StandardError
    def initialize(obj)
      super("Please declare #{obj} in config/initializers/chron.rb")
    end
  end
  class UnregisteredObservation < StandardError
    def initialize(obj)
      super("Please declare #{obj} in config/initializers/chron.rb")
    end
  end

  def self.configure(&block)
    instance_exec &block if block_given?
  end

  def self.observe(model_name)
    add_observable_resource model_name
    @observing = model_name
    yield
    @observing = nil
  end

  def self.at(column_name)
    add_observation @observing, column_name, nil
  end
end

require "chron/job"
require "chron/observable"
require "chron/observable/job"
require "chron/observable/record_job"
