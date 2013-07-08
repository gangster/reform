module Reform
  module Generators
    class ControllerGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)

      desc "This generator creates a Controller object inside of app/controllers"

      def create_workflow
        unless File.exists?(File.join(Rails.root, "app", "controllers", "#{name}_controller.rb"))
          generate "reform:workflow", name
        end
        template "controller.rb", "app/controllers/#{name.pluralize}_controller.rb"
      end

      private

      def class_prefix
        name.camelize
      end
    end
  end
end
