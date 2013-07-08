require_relative '../reform/property_helpers'

module Reform
  module Generators
    class ReformGenerator < Rails::Generators::NamedBase
      include Reform::Generators::PropertyHelpers

      source_root File.expand_path("../templates", __FILE__)

      desc "Generates the form, controller, workflow and service objects for a model"

      def generate_all
        generate "reform:form", "#{name} #{props.join(" ")}"
        generate "reform:controller", name
      end
    end
  end
end
