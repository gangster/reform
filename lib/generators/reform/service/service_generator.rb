module Reform
  module Generators
    class ServiceGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)

      desc "This generator creates a Service object inside of app/services/services"

      def create_service
          template "service.rb", "app/services/services/#{name}_crud.rb"
      end

      private

      def class_prefix
        name.camelize
      end
    end
  end
end
