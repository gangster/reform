require_relative '../../reform/property_helpers'

module Reform
  module Generators
    class FormGenerator < Rails::Generators::NamedBase
      include Reform::Generators::PropertyHelpers

      source_root File.expand_path("../templates", __FILE__)
      class_option :"skip-activerecord", type: :boolean, :default => false, :desc => "Skip ActiveRecord integration"

      desc "This generator creates a Form object inside of app/forms"

      def create_form
        @skip_activerecord = options["skip-activerecord"]
        initializer "reform", "require 'reform/rails'"
        template "form.rb", "app/forms/forms/#{name}_form.rb"
      end

      private


      def skip_activerecord?
        @skip_activerecord
      end

      def class_prefix
        name.camelize
      end
    end
  end
end
