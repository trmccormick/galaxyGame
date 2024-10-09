# app/models/units/biogas_unit.rb
module Units
    class BiogasUnit < BaseUnit
    attr_accessor :biogas_production_rate, :digestate_yield
  
    def initialize(name, base_materials, operating_requirements, input_resources, output_resources)
      super(name, base_materials, operating_requirements, input_resources, output_resources)
      @biogas_production_rate = 0
      @digestate_yield = 0
    end
  
    protected
  
    def consume_resources
      # Define the amount of each input needed for biogas production
      biomass_needed = 10        # Example: biomass in units
      sludge_needed = 5          # Example: sludge in units (optional)
      waste_water_needed = 15    # Example: waste water in units
  
      # Check if sufficient resources are available
      if Resource.resources[:biomass] >= biomass_needed && 
         Resource.resources[:waste_water] >= waste_water_needed
  
        puts "#{name} is processing #{biomass_needed} units of biomass and #{waste_water_needed} units of waste water."
  
        # Consume the resources
        Resource.consume(:biomass, biomass_needed)
        Resource.consume(:waste_water, waste_water_needed)
  
        # If sludge is available, consume it
        if Resource.resources[:sludge] >= sludge_needed
          puts "#{name} is processing #{sludge_needed} units of sludge."
          Resource.consume(:sludge, sludge_needed)
        else
          puts "#{name} has insufficient sludge; proceeding without it."
        end
  
        # Calculate biogas production
        biogas_produced = (biomass_needed + (sludge_needed if Resource.resources[:sludge] >= sludge_needed) * 0.5 + waste_water_needed * 0.2) * 0.6 # Conversion factors
        puts "#{name} produces #{biogas_produced} units of biogas."
        Resource.add(:biogas, biogas_produced)
  
        # Produce digestate (solid waste)
        digestate_generated = (biomass_needed * 0.4 + (sludge_needed if Resource.resources[:sludge] >= sludge_needed) * 0.3 + waste_water_needed * 0.1)
        puts "#{name} produces #{digestate_generated} units of digestate."
        Resource.add(:digestate, digestate_generated)
  
        # Produce treated water (liquid waste)
        treated_water_generated = (biomass_needed * 0.3 + waste_water_needed * 0.5) * 0.4
        puts "#{name} produces #{treated_water_generated} units of treated water."
        Resource.add(:treated_water, treated_water_generated)
  
        # Additional waste material (if applicable)
        additional_waste = (biomass_needed * 0.2 + (sludge_needed if Resource.resources[:sludge] >= sludge_needed) * 0.1)
        puts "#{name} produces #{additional_waste} units of additional waste."
        Resource.add(:additional_waste, additional_waste)
  
      else
        puts "Not enough resources available for biogas production!"
      end
    end
  end
end
  