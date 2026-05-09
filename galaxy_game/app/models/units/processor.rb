# app/models/units/processor.rb
module Units
  class Processor < BaseUnit
    def energy_consumption
      operational_data&.dig('energy_consumption') || 0
    end

    def output_resources
      operational_data['output_resources'] ||= {}
    end

    def produce_resource(resource, amount)
      output_resources[resource] ||= 0
      output_resources[resource] += amount
      save if respond_to?(:save)
    end
  end
end
