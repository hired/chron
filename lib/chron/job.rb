class Chron::Job < ActiveJob::Base
  def perform
    Chron.observable_resources.each do |class_name|
      Chron::Observable::Job.perform_later(class_name)
    end
  end
end
