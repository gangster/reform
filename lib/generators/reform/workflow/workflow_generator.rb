module Reform
  module Generators
    class WorkflowGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)

      desc "This generator creates a Workflow object inside of app/workflows/workflows"

      def create_workflow
        unless File.exists?(File.join(Rails.root, "app", "services", "services", "#{name}_crud.rb"))
          generate "reform:service", name
        end
        template "workflow.rb", "app/workflows/workflows/#{name}_workflow.rb"
      end

      private

      def class_prefix
        name.camelize
      end
    end
  end
end
