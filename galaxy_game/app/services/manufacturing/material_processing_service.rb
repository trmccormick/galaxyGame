# frozen_string_literal: true

module Manufacturing
  class MaterialProcessingService

    def initialize(settlement)
      @settlement = settlement
    end

    # Generic process method for any material processing unit
    def process(unit, input_material, input_amount)
      # Validate input inventory
      unless @settlement.inventory.has_item?(input_material, input_amount)
        return { error: "Insufficient #{input_material}" }
      end

      # Load operational data for the unit
      operational_data = Lookup::UnitLookupService.new.find_unit(unit.unit_type)
      raise "Operational data not found for unit type: #{unit.unit_type}" unless operational_data

      # Determine processing type from geosphere_processing types
      geo_types = Array(operational_data.dig("processing_capabilities", "geosphere_processing", "types"))
      processing_type = if geo_types.include?("volatile_extraction")
        :volatiles_extraction
      else
        :thermal_extraction
      end

      # TODO: operational data JSON needs explicit processing_time_hours field
      # Currently using maintenance_interval_hours as proxy — add to unit JSON templates
      production_time = operational_data.dig("operational_properties", "maintenance_interval_hours") || 24.0

      MaterialProcessingJob.create!(
        settlement: @settlement,
        unit: unit,
        processing_type: processing_type,
        input_material: input_material,
        input_amount: input_amount,
        status: :pending,
        production_time_hours: production_time,
        operational_data: { 'unit_type' => unit.unit_type }
      )
    end

    # Complete a processing job, using live operational data and geosphere for zero-amount outputs
    def complete_job(job)
      unit = job.unit
      operational_data = Lookup::UnitLookupService.new.find_unit(unit.unit_type)
      raise "Operational data not found for unit type: #{unit.unit_type}" unless operational_data

      output_resources = operational_data["output_resources"] || []
      geosphere_eff = operational_data.dig("processing_capabilities", "geosphere_processing", "efficiency") || 1.0

      # Remove input material
      @settlement.inventory.remove_item(job.input_material, job.input_amount, @settlement, {})

      output_resources.each do |out|
        out_id = out["id"]
        out_amount = out["amount"].to_f
        if out_amount > 0
          # Case A: Non-zero output amount — scale by input and efficiency
          produced = job.input_amount * (out_amount / (operational_data["input_resources"]&.first&.dig("amount") || 1.0)) * geosphere_eff
          @settlement.inventory.add_item(out_id, produced, @settlement, {})
        else
          # Case B: Zero output amount — handle by output id
          geosphere = @settlement.celestial_body&.geosphere
          crust_volatiles = geosphere&.crust_composition&.dig("volatiles") || {}
          case out_id
          when 'extracted_water'
            h2o = crust_volatiles['H2O'] || crust_volatiles['h2o']
            if h2o
              produced = job.input_amount * (h2o.to_f / 100.0) * geosphere_eff
              @settlement.inventory.add_item('extracted_water', produced, @settlement, {})
            end
          when 'extracted_gases'
            crust_volatiles.each do |volatile, percent|
              next if volatile.to_s.downcase == 'h2o'
              produced = job.input_amount * (percent.to_f / 100.0) * geosphere_eff
              @settlement.inventory.add_item(volatile, produced, @settlement, {})
            end
          when 'depleted_regolith'
            # Depleted regolith = input - all extracted volatiles
            total_extracted = crust_volatiles.values.map { |percent| job.input_amount * (percent.to_f / 100.0) * geosphere_eff }.sum
            produced = job.input_amount - total_extracted
            @settlement.inventory.add_item('depleted_regolith', produced, @settlement, {})
          end
        end
      end

      job.complete!
    end

    # (No private methods remain)
  end
end