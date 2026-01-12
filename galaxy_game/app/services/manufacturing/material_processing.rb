class Manufacturing::MaterialProcessing
  def initialize(processor_unit, material_input)
    @processor = processor_unit
    @input = material_input
    @temperature = processor_unit.temperature # Current operating temperature
    @pressure = processor_unit.pressure       # Current chamber pressure
  end

  def process_material
    return unless @input && @input.composition
    
    results = {
      gases: extract_gases,
      solids: process_solids,
      trace_elements: collect_trace_elements
    }

    # Create processed material for construction
    if results[:solids].present?
      create_construction_material(results[:solids])
    end

    results
  end

  private

  def extract_gases
    return {} unless @input.composition[:oxides]
    
    extracted = {}
    @input.composition[:oxides].each do |oxide, percentage|
      # Extract oxygen based on molecular composition
      if can_extract_oxygen?(oxide)
        oxygen_yield = calculate_oxygen_yield(oxide, percentage)
        extracted["O2"] = (extracted["O2"] || 0) + oxygen_yield
      end
    end
    extracted
  end

  def process_solids
    return {} unless @input.composition[:oxides]
    
    processed = {}
    @input.composition[:oxides].each do |oxide, percentage|
      # Convert oxides to base materials
      base_material = extract_base_material(oxide)
      processed[base_material] = (processed[base_material] || 0) + 
                                calculate_material_yield(oxide, percentage)
    end
    processed
  end

  def create_construction_material(processed_solids)
    Blueprint::ConstructionMaterial.new(
      base_materials: processed_solids,
      properties: {
        compression_strength: calculate_strength,
        thermal_resistance: calculate_thermal_properties,
        radiation_shielding: calculate_shielding_value
      }
    )
  end
end