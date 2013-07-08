module Reform
  module Generators
    class FormGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)
      argument :model, type: :string, banner: "model_name"
      argument :props, type: :array, default: [], banner: "model:property"
      class_option :"skip-activerecord", type: :boolean, :default => false, :desc => "Skip ActiveRecord integration"

      desc "This generator creates a Form object inside of app/forms"

      def create_form
        @skip_activerecord = options["skip-activerecord"]
        @has_model = false

        if model.include?(":") then props.push model else @has_model = true end
        begin
          props.map { |prop| parse_model_property(prop) }.map do |hash|
            if properties[hash.keys[0]]
              properties[hash.keys[0]] << hash.values[0]
            else
              properties[hash.keys[0]] = [hash.values[0]]
            end
          end
          initializer "reform", "require 'reform/rails'"
          template "form.rb", "app/forms/forms/#{name}_form.rb"
        rescue ArgumentError
          puts "Property arguments must take the form model:property"
        end
      end

      private

      def parse_model_property(prop)
        raise ArgumentError if prop.split(":").length < 2
        Hash[*prop.split(":")]
      end

      def skip_activerecord?
        @skip_activerecord
      end

      def properties
        @properties ||= {}
      end

      def class_prefix
        name.camelize
      end

      def has_model?
        @has_model
      end
    end
  end
end
