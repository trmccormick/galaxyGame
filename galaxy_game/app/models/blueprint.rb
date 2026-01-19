# app/models/blueprint.rb
class Blueprint < ApplicationRecord
    belongs_to :player
  
    validates :name, presence: true
    validates :current_research_level, numericality: { greater_than_or_equal_to: 0 }
    validates :material_efficiency, numericality: { greater_than_or_equal_to: 0 }
    validates :time_efficiency, numericality: { greater_than_or_equal_to: 0 }
    validates :licensed_runs_remaining, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
    # Returns a hash of material names to required amounts, using the lookup service and JSON data
    def materials
      service = Lookup::BlueprintLookupService.new
      data = service.find_blueprint(name)
      return {} unless data && data['required_materials']
      data['required_materials'].transform_values { |v| v['amount'] }
    end

    # Check if blueprint has remaining licensed runs
    def can_manufacture?(quantity = 1)
      return true if licensed_runs_remaining.nil? # Unlimited for NPCs
      licensed_runs_remaining >= quantity
    end

    # Consume licensed runs after manufacturing
    def consume_runs(quantity = 1)
      return if licensed_runs_remaining.nil? # Unlimited for NPCs
      update!(licensed_runs_remaining: licensed_runs_remaining - quantity)
    end

    # Example to calculate derived efficiencies if needed
    def calculate_efficiencies
      service = Lookup::BlueprintLookupService.new
      json_data = service.find_blueprint(name)
      return unless json_data && json_data['research_effects']

      base_material_efficiency = json_data['research_effects']['material_efficiency']['start_value']
      improvement_per_level = json_data['research_effects']['material_efficiency']['improvement_percentage_per_research_level']
      self.material_efficiency = base_material_efficiency + (current_research_level * improvement_per_level)

      base_time_efficiency = json_data['research_effects']['time_efficiency']['start_value']
      improvement_per_time = json_data['research_effects']['time_efficiency']['improvement_percentage_per_research_level']
      self.time_efficiency = base_time_efficiency + (current_research_level * improvement_per_time)
    end
  end
