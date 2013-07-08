module Reform
  module Generators
    module PropertyHelpers
      extend ActiveSupport::Concern

      included do
        argument :props, type: :array, default: [], banner: "model:property"
      end

      def parse_properties(props)
        properties = {}
        begin
          props.map { |prop| parse_model_property(prop) }.map do |hash|
            if properties[hash.keys[0]]
              properties[hash.keys[0]] << hash.values[0]
            else
              properties[hash.keys[0]] = [hash.values[0]]
            end
          end
        rescue ArgumentError
          puts "Property arguments must take the form model:property"
        end
          properties
      end

      def properties
        @properties ||= parse_properties(props)
      end

      def parse_model_property(prop)
        raise ArgumentError if prop.split(":").length < 2
        Hash[*prop.split(":")]
      end
    end
  end
end
