module Chron::Observable
  extend ActiveSupport::Concern

  included do |base|
    Chron.add_observable_resource(base)
  end

  module ClassMethods
    def at_time(column, &block)
      Chron.add_observation(to_s, column, block)
    end
  end
end
