# frozen_string_literal: true

module Manufacturing
  class RegolithProcessingService
    def initialize(settlement)
      @settlement = settlement
    end

    # Process regolith using temperature-based extraction
    # This method handles the legacy approach for backward compatibility
    def process_with_temperature(regolith_item, temperature, efficiency = 1.0)
      return { error: "Item is not regolith" } unless regolith_item.name.end_with?('Regolith')
      return { error: "Regolith amount must be positive" } unless regolith_item.amount.to_f > 0

      # Get composition - prefer location-specific data over generic lookup
      composition = get_regolith_composition(regolith_item)

      processed_comp = {}
      extracted = {}

      composition.each do |material|
        if material['material'] == 'Oxygen'
          # Extract oxygen based on temperature and efficiency
          extracted['Oxygen'] = material['percentage'] * efficiency
        else
          # Remaining materials stay in processed regolith
          processed_comp[material['material']] = material['percentage']
        end
      end

      # Execute processing in transaction
      ActiveRecord::Base.transaction do
        processed = nil
        if regolith_item.amount.to_f > 0
          # Create new processed regolith item only if amount is positive
          processed = Item.create!(
            name: "Processed Regolith",
            amount: regolith_item.amount,
            material_type: :processed_material,
            storage_method: :bulk_storage,
            owner: regolith_item.owner,
            inventory: regolith_item.inventory,
            metadata: {
              'composition' => processed_comp,
              'origin_material' => regolith_item.name,
              'processing_temperature' => temperature,
              'processing_efficiency' => efficiency,
              'source_body' => regolith_item.metadata['source_body']
            }
          )
        end

        # Create extracted oxygen item if any
        if extracted['Oxygen'].to_f.positive? && regolith_item.amount.to_f > 0
          Item.create!(
            name: "Oxygen",
            amount: (regolith_item.amount * extracted['Oxygen'] / 100.0).round(2),
            material_type: :gas,
            storage_method: :pressurized_storage,
            owner: regolith_item.owner,
            inventory: regolith_item.inventory,
            metadata: {
              'source' => 'regolith_processing',
              'processing_temperature' => temperature,
              'processing_efficiency' => efficiency
            }
          )
        end

        # Remove original regolith
        regolith_item.destroy

        {
          success: true,
          processed_regolith: processed,
          oxygen_extracted: extracted['Oxygen'].to_f,
          temperature: temperature,
          efficiency: efficiency
        }
      end
    rescue => e
      { error: "Processing failed: #{e.message}" }
    end

    # Process regolith using a processor unit
    # This method integrates with the manufacturing system
    def process_with_unit(regolith_item, processor_unit)
      return { error: "Item is not regolith" } unless regolith_item.name == "Regolith"
      return { error: "No source body information" } unless regolith_item.metadata["source_body"].present?
      return { error: "Regolith amount must be positive" } unless regolith_item.amount.to_f > 0

      body = ::CelestialBodies::CelestialBody.find_by(identifier: regolith_item.metadata["source_body"])
      return { error: "Unknown celestial body" } unless body&.geosphere&.crust_composition

      # Get processing parameters from the unit (assuming it has temperature/pressure attributes)
      temperature = processor_unit.respond_to?(:temperature) ? processor_unit.temperature : 1000
      pressure = processor_unit.respond_to?(:pressure) ? processor_unit.pressure : 1.0
      efficiency = processor_unit.respond_to?(:efficiency) ? processor_unit.efficiency : 1.0

      # Process the composition based on temperature and pressure
      processed_comp = {}
      extracted = {}

      body.geosphere.crust_composition.each do |element, percentage|
        # Simple processing logic: extract oxygen at high temperatures
        if element == 'O' && temperature > 800
          extracted['Oxygen'] = percentage * efficiency
        else
          processed_comp[element] = percentage
        end
      end

      # Execute processing in transaction
      ActiveRecord::Base.transaction do
        processed = nil
        if regolith_item.amount.to_f > 0
          # Create processed regolith only if amount is positive
          processed = Item.create!(
            name: "Processed Regolith",
            amount: regolith_item.amount,
            material_type: :processed_material,
            storage_method: :bulk_storage,
            owner: regolith_item.owner,
            inventory: regolith_item.inventory,
            metadata: {
              'composition' => processed_comp,
              'origin_material' => regolith_item.name,
              'source_body' => regolith_item.metadata['source_body'],
              'processing_temperature' => temperature,
              'processing_pressure' => pressure,
              'processing_efficiency' => efficiency
            }
          )
        end

        # Create extracted oxygen if any
        if extracted['Oxygen'].to_f.positive? && regolith_item.amount.to_f > 0
          Item.create!(
            name: "Oxygen",
            amount: (regolith_item.amount * extracted['Oxygen'] / 100.0).round(2),
            material_type: :gas,
            storage_method: :pressurized_storage,
            owner: regolith_item.owner,
            inventory: regolith_item.inventory,
            metadata: {
              'source' => 'regolith_processing',
              'source_body' => regolith_item.metadata['source_body'],
              'processing_temperature' => temperature,
              'processing_pressure' => pressure
            }
          )
        end

        # Remove original regolith
        regolith_item.destroy

        {
          success: true,
          processed_regolith: processed,
          oxygen_extracted: extracted['Oxygen'].to_f,
          temperature: temperature,
          pressure: pressure,
          efficiency: efficiency
        }
      end
    rescue => e
      { error: "Processing failed: #{e.message}" }
    end

    private

    # Get regolith composition, preferring location-specific data
    def get_regolith_composition(regolith_item)
      # First try to get location-specific composition
      if regolith_item.metadata["source_body"].present?
        body = ::CelestialBodies::CelestialBody.find_by(identifier: regolith_item.metadata["source_body"])
        if body&.geosphere&.crust_composition
          # Convert crust composition to the expected format
          return body.geosphere.crust_composition.map do |element, percentage|
            { 'material' => element, 'percentage' => percentage }
          end
        end
      end

      # Fall back to generic material properties
      regolith_item.material_properties['smelting_output'] || []
    end
  end
end