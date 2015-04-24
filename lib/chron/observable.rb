module Chron::Observable
  extend ActiveSupport::Concern

  included do |base|
    unless Chron.observable_resources.include?(base.to_s)
      raise Chron::UnregisteredObservable.new(base)
    end
  end

  module ClassMethods
    def at_time(column, &block)
      if Chron.observations_for(to_s).include?(column.to_sym)
        Chron.add_observation(to_s, column, block)
      else
        raise Chron::UnregisteredObservation.new(to_s, column)
      end
    end
  end
end
