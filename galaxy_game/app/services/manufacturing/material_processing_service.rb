# frozen_string_literal: true

module Manufacturing
  class MaterialProcessingService
    # Constant data needed by the service for reporting
    PVE_DATA = {
      input_processed_kg: 5.0,
      output_gases_kg: 0.06,
      output_water_kg: 0.10,
      output_depleted_regolith_kg: 4.85
    }.freeze

    TEU_DATA = {
      input_raw_kg: 10.0,
      output_processed_kg: 9.95
    }.freeze

    # Gas Composition Ratios (based on total mass)
    GASSES_RATIO = {
      "hydrogen": 0.50,
      "carbon_monoxide": 0.25,
      "helium": 0.05,
      "neon": 0.20
    }.freeze

    def initialize(settlement)
      @settlement = settlement
    end

    # Process raw regolith through Thermal Extraction Unit (TEU)
    # Converts raw regolith to processed regolith
    def thermal_extraction(unit, input_material, input_amount)
      MaterialProcessingJob.create!(
        settlement: @settlement,
        unit: unit,
        processing_type: :thermal_extraction,
        input_material: input_material,
        input_amount: input_amount,
        status: :pending,
        production_time_hours: 24.0, # TEU_DATA[:input_raw_kg] based default
        operational_data: { 'cycles' => 1 }
      )
    end

    # Process processed regolith through Planetary Volatiles Extractor (PVE)
    # Converts processed regolith to inert waste + water + gases
    def volatiles_extraction(unit, input_material, input_amount)
      MaterialProcessingJob.create!(
        settlement: @settlement,
        unit: unit,
        processing_type: :volatiles_extraction,
        input_material: input_material,
        input_amount: input_amount,
        status: :pending,
        production_time_hours: 36.0, # PVE_DATA[:input_processed_kg] based default
        operational_data: { 'cycles' => 1 }
      )
    end

    def complete_job(job)
      case job.processing_type
      when 'thermal_extraction'
        complete_thermal_extraction(job)
      when 'volatiles_extraction'
        complete_volatiles_extraction(job)
      end
    end

    private

    def complete_thermal_extraction(job)
      cycles = job.operational_data['cycles']
      raw_consumed = cycles * TEU_DATA[:input_raw_kg]
      processed_produced = cycles * TEU_DATA[:output_processed_kg]

      ActiveRecord::Base.transaction do
        # Consume raw regolith
        raw_item = @settlement.inventory.items.find_by!(name: "raw_regolith")
        new_amount = [raw_item.amount - raw_consumed, 0].max
        raw_item.update!(amount: new_amount)

        # Propagate composition metadata if present
        metadata = raw_item.metadata&.dup || {}
        processed_metadata = { "source_process" => "thermal_extraction", "source_materials" => ["raw_regolith"] }
        processed_metadata["composition"] = metadata["composition"] if metadata["composition"]

        # @settlement.inventory.add_item("processed_regolith", processed_produced, @settlement.owner, processed_metadata)
        Item.create!(
          inventory: @settlement.inventory,
          name: "processed_regolith",
          amount: processed_produced,
          owner: @settlement.owner,
          storage_method: 'bulk_storage',
          metadata: processed_metadata
        )
      end
    end

    def complete_volatiles_extraction(job)
      cycles = job.operational_data['cycles']
      processed_consumed = cycles * PVE_DATA[:input_processed_kg]
      inert_waste_produced = cycles * PVE_DATA[:output_depleted_regolith_kg]
      water_produced = cycles * PVE_DATA[:output_water_kg]
      gases_produced = cycles * PVE_DATA[:output_gases_kg]

      ActiveRecord::Base.transaction do
        # Consume processed regolith
        processed_item = @settlement.inventory.items.find_by!(name: "processed_regolith")
        new_amount = [processed_item.amount - processed_consumed, 0].max
        processed_item.update!(amount: new_amount)

        # Add inert waste, propagate composition
        inert_metadata = {
          "source_process" => "volatiles_extraction",
          "source_materials" => ["processed_regolith"]
        }
        processed_metadata = processed_item.metadata
        if processed_metadata && processed_metadata["composition"]
          inert_metadata["composition"] = processed_metadata["composition"]
        end
        # @settlement.inventory.add_item("inert_regolith_waste", inert_waste_produced, @settlement.owner, inert_metadata)
        Item.create!(
          inventory: @settlement.inventory,
          name: "inert_regolith_waste",
          amount: inert_waste_produced,
          owner: @settlement.owner,
          storage_method: 'bulk_storage',
          metadata: inert_metadata
        )

        # Add water
        # @settlement.inventory.add_item("water", water_produced, @settlement.owner)
        Item.create!(
          inventory: @settlement.inventory,
          name: "water",
          amount: water_produced,
          owner: @settlement.owner,
          storage_method: 'bulk_storage',
          metadata: {}
        )

        # Add gases
        GASSES_RATIO.each do |gas, ratio|
          # @settlement.inventory.add_item(gas.to_s, gases_produced * ratio, @settlement.owner)
          Item.create!(
            inventory: @settlement.inventory,
            name: gas.to_s,
            amount: gases_produced * ratio,
            owner: @settlement.owner,
            storage_method: 'bulk_storage',
            metadata: {}
          )
        end

        # Atmospheric Handshake: Update planetary atmosphere with extracted gases
        if @settlement.location.celestial_body.atmosphere.respond_to?(:absorb_gas_payload)
          @settlement.location.celestial_body.atmosphere.absorb_gas_payload(gases_produced, GASSES_RATIO)
        end
      end
    end

    def teu_unit_operational?(unit)
      # Placeholder - would check unit operational status
      unit.present? && unit.is_a?(Units::BaseUnit)
    end

    def pve_unit_operational?(unit)
      # Placeholder - would check unit operational status
      unit.present? && unit.is_a?(Units::BaseUnit)
    end
  end
end