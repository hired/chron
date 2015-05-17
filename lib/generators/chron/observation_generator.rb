module Chron
  module Generators
    class ObservationGenerator < ::Rails::Generators::Base
      CONFIG_PATH = 'config/initializers/chron.rb'
      source_root File.expand_path('../templates', __FILE__)
      argument :model, type: :string, required: true
      argument :column_name, type: :string, required: true
      argument :deprecated_reactor_event, type: :string, default: ''

      def add_configuration
        template 'configuration.rb.erb', CONFIG_PATH unless File.exists?(CONFIG_PATH)
      end

      def add_observable_to_configuration
        unless config_file.match(/observe '#{model_name}' do/)
          gsub_file CONFIG_PATH, /(Chron.configure do)/mi do |match|
            "#{match}\n  observe '#{model_name}' do\n  end\n"
          end
        end
      end

      def add_observation_to_configuration
        gsub_file CONFIG_PATH, /(observe '#{model_name}' do)/mi do |match|
          "#{match}\n    at :#{column_name}"
        end
      end

      def mix_observable_into_model
        return if model_already_includes_chron?
        gsub_file model_path, /(class #{model_name} < .*$)/i do |match|
          "#{match}\n  include Chron::Observable"
        end
      end

      def add_observation_to_model
        if model_file_already_observes_column?
          say 'Model already observes this column. Please add your logic to the existing observation block.'
          return
        end
        optional_publish = deprecated_reactor_event.present? && "publish :#{deprecated_reactor_event}"
        gsub_file model_path, /(include Chron::Observable)/mi do |match|
          "#{match}\n\n  at_time(:#{column_name}) { #{optional_publish} }"
        end
      end

      def add_observation_timestamp_columns_to_model
        template "migration.rb.erb", "db/migrate/#{Time.now.strftime("%Y%m%d%H%M%S")}_add_chron_observation_timestamps_for_#{column_name}_to_#{table_name}.rb"
      end

      private

      def model_path
        "app/models/#{ model }.rb"
      end

      def model_name
        model.camelize.gsub('/', '::')
      end

      def table_name
        model.camelize.constantize.table_name
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

      def config_file
        @config_file ||= File.read(CONFIG_PATH)
      end
    end
  end
end
