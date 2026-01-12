# app/models/water_treatment.rb
module Units
    class WaterTreatment < BaseUnit
    attr_accessor :treated_water_yield, :waste_material_yield, :sludge_yield
  
    def initialize(name, base_materials, operating_requirements, input_resources, output_resources)
      super(name, base_materials, operating_requirements, input_resources, output_resources)
      @treated_water_yield = 0
      @waste_material_yield = 0
      @sludge_yield = 0
    end
  
    protected
  
    def consume_resources
      # Amount of wastewater needed to produce treated water
      wastewater_needed = 10
  
      if Resource.resources[:waste_water] >= wastewater_needed
        puts "#{name} is treating #{wastewater_needed} liters of wastewater."
        Resource.consume(:waste_water, wastewater_needed)
  
        # Produce treated water
        treated_water_produced = wastewater_needed  # Assume a 1:1 ratio for simplicity
        puts "#{name} produces #{treated_water_produced} liters of treated water."
        Resource.add(:water, treated_water_produced)  # Add treated water back to the water supply
  
        # Generate waste material (e.g., sludge)
        sludge_generated = wastewater_needed * 0.1  # Assume 10% of input wastewater becomes sludge
        puts "#{name} produces #{sludge_generated} units of sludge."
        Resource.add(:sludge, sludge_generated)  # Add sludge to resources
      else
        puts "Not enough wastewater available for treatment!"
      end
    end
  end
end
  