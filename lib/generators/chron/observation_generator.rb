module Chron
  module Generators
    class ObservationGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      argument :model, type: :string, required: true
      argument :column_name, type: :string, required: true
      argument :table_name_arg, type: :string, required: false

      def mix_observable_into_model
        return if model_already_includes_chron?
        gsub_file model_path, /(class #{model.camelize.gsub('/', '::')} < .*$)/i do |match|
          "#{match}\n  include Chron::Observable"
        end
      end

      def add_observation_to_model
        if model_file_already_observes_column?
          say 'Model already observes this column. Please add your logic to the existing observation block.'
          return
        end
        gsub_file model_path, /(include Chron::Observable)/mi do |match|
          "#{match}\n\n  at_time :#{column_name} do\n    # do anything for this resource (self) at the given time\n  end\n"
        end
      end

      def add_observation_timestamp_columns_to_model
        template "migration.rb.erb", "db/migrate/#{Time.now.strftime("%Y%m%d%H%M%S")}_add_chron_observation_timestamps_for_#{column_name}_to_#{table_name}.rb"
      end

      private

      def model_path
        "app/models/#{ model }.rb"
      end

      def table_name
        table_name_arg || model.gsub('/','_').underscore.pluralize
      end

      def model_already_includes_chron?
        model_file.match(/include Chron::Observable/)
      end

      def model_file
        @model_file ||= File.read(model_path)
      end

      def model_file_already_observes_column?
        model_file.match(/at_time :#{column_name}/)
      end
    end
  end
end
