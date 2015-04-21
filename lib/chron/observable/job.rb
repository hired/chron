class Chron::Observable::Job < Chron::Job
  def perform(class_name)
    Chron.observables_for(class_name).each do |column|
      observe_records_for(class_name, column)
    end
  end

  private

  def observe_records_for(class_name, column)
    class_name.constantize
        .select(:id).where(column => Chron::POLLING_RANGE.call).find_each do |record|
      Chron::Observable::RecordJob.perform_later(class_name, column.to_s, record.id)
    end
  end
end
