class Chron::Observable::Job < Chron::Job
  def perform(class_name)
    Chron.observables_for(class_name).each do |column|
      AggregateObservation.new(class_name, column).perform
    end
  end

  private

  class AggregateObservation
    attr_accessor :observable_class, :column

    def initialize(class_name, column)
      self.observable_class, self.column = [class_name.constantize, column]
    end

    def perform
      schedule_record_jobs
      demarcate_observed_records
    end

    private

    def schedule_record_jobs
      unobserved_records.find_each do |record|
        Chron::Observable::RecordJob.perform_later(observable_class.to_s, column.to_s, record.id)
      end
    end

    def unobserved_records
      observable_class
          .where(column => Time.at(0)...polling_time)
          .where(poller_demarcation => nil)
    end

    def poller_demarcation
      "#{column}__observation_started_at"
    end

    def demarcate_observed_records
      unobserved_records.update_all poller_demarcation => polling_time
    end

    def polling_time
      @polling_time ||= Time.current
    end
  end
end
