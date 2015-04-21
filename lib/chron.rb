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

  def self.observables_for(class_name)
    observable = OBSERVABLES[class_name]
    raise UnknownObservable if observable.blank?
    observable.keys
  end

  def self.observation(class_name, column)
    observation = OBSERVABLES[class_name][column]
    raise UnknownObservation if observation.blank?
    observation
  end

  def self.add_observation(class_name, column, block)
    observable = OBSERVABLES[class_name]
    raise ExistingObservable if observable[column].present?
    observable[column] = block
  end

  class ExistingObservable < StandardError; end
  class UnknownObservable < StandardError; end
  class UnknownObservation < StandardError; end

  POLLING_RANGE = -> { (Time.current - POLLING_WINDOW)..(Time.current + POLLING_WINDOW) }
  POLLING_WINDOW = 5 * 60
end

require "chron/job"
require "chron/observable"
require "chron/observable/job"
require "chron/observable/record_job"
