# frozen_string_literal: true

module Manufacturing
  class MaterialProcessingService

    def initialize(settlement)
      @settlement = settlement
    end

    # Create a processing job for a specific unit type and job type
    def create_processing_job(job_type:, unit_type:)
      # Look up unit operational data
      lookup_service = Lookup::UnitLookupService.new
      unit_data = lookup_service.find_unit(unit_type)
      
      unless unit_data
        raise "Unit type '#{unit_type}' not found"
      end

      # Determine processing type from subcategory
      processing_type = case unit_data.dig("subcategory")
      when "volatile_extraction"
        :volatiles_extraction
      when "thermal_extraction"
        :thermal_extraction
      else
        :thermal_extraction
      end

      # TODO: operational data JSON needs explicit processing_time_hours field
      # Currently using maintenance_interval_hours as proxy — add to unit JSON templates
      production_time = unit_data.dig("operational_properties", "maintenance_interval_hours") || 24.0

      Job.create!(
        job_type: job_type.to_sym,
        settlement: @settlement,
        owner: @settlement.owner,
        output_type: 'processed_regolith',
        start_date: Time.current,
        completes_at: production_time.hours.from_now,
        status: :pending,
        operational_data: {
          'unit_type' => unit_type,
          'processing_type' => processing_type.to_s,
          'production_time_hours' => production_time
        }
      )
    end

    # Generic process method for any material processing unit
    def process(unit, input_material, input_amount)
      # Validate input inventory
      unless @settlement.inventory.has_item?(input_material, input_amount)
        return { error: "Insufficient #{input_material}" }
      end

      # Load operational data for the unit
      operational_data = unit.operational_data
      raise "Operational data not found for unit type: #{unit.unit_type}" unless operational_data

      # Determine processing type from subcategory
      processing_type = case operational_data.dig("subcategory")
      when "volatile_extraction"
        :volatiles_extraction
      when "thermal_extraction"
        :thermal_extraction
      else
        :thermal_extraction
      end

      # TODO: operational data JSON needs explicit processing_time_hours field
      # Currently using maintenance_interval_hours as proxy — add to unit JSON templates
      production_time = operational_data.dig("operational_properties", "maintenance_interval_hours") || 24.0

      Job.create!(
        job_type: :material_processing,
        settlement: @settlement,
        owner: @settlement.owner,
        output_type: 'processed_regolith',
        start_date: Time.current,
        completes_at: 1.hour.from_now,
        status: :pending,
        operational_data: {
          'unit_type' => unit.unit_type,
          'processing_type' => processing_type.to_s,
          'input_material' => input_material,
          'input_amount' => input_amount,
          'production_time_hours' => production_time
        }
      )
    end

    # Complete a processing job, using live operational data and geosphere for zero-amount outputs
    def complete_job(job)
      od = job.operational_data.is_a?(String) ? JSON.parse(job.operational_data) : job.operational_data
      unit_type = od['unit_type']
      processing_type = od['processing_type']
      input_material = od['input_material']
      input_amount = od['input_amount']
      production_time = od['production_time_hours']

      operational_data = Lookup::UnitLookupService.new.find_unit(unit_type)
      raise "Operational data not found for unit type: #{unit_type}" unless operational_data

      output_resources = operational_data["output_resources"] || []
      geosphere_eff = operational_data.dig("processing_capabilities", "geosphere_processing", "efficiency") || 1.0

      # Remove input material
      @settlement.inventory.remove_item(input_material, input_amount, @settlement, {})

      output_resources.each do |out|
        out_id = out["id"]
        out_amount = out["amount"].to_f
        if out_amount > 0
          # Case A: Non-zero output amount — scale by input and efficiency
          produced = input_amount * (out_amount / (operational_data["input_resources"]&.first&.dig("amount") || 1.0)) * geosphere_eff
          @settlement.inventory.add_item(out_id, produced, @settlement, {})
        else
          # Case B: Zero output amount — handle by output id
          geosphere = @settlement.celestial_body&.geosphere
          raw_volatiles = geosphere&.stored_volatiles
          raw_volatiles = raw_volatiles.is_a?(String) ? JSON.parse(raw_volatiles) : raw_volatiles
          raw_volatiles ||= {}
          # Convert stored_volatiles mass structure to percentage hash for extraction
          # stored_volatiles format: { "H2O" => { "ice_caps" => mass, ... }, ... }
          # Extract total mass per volatile then normalize to percentages
          total_volatile_mass = raw_volatiles.values.map { |v| v.is_a?(Hash) ? v.values.sum : v.to_f }.sum
          crust_volatiles = if total_volatile_mass > 0
            raw_volatiles.transform_values do |v|
              mass = v.is_a?(Hash) ? v.values.sum : v.to_f
              (mass / total_volatile_mass) * 100.0
            end
          else
            {}
          end
          case out_id
          when 'H2O'
            h2o = crust_volatiles['H2O'] || crust_volatiles['h2o']
            if h2o
              produced = input_amount * (h2o.to_f / 100.0) * geosphere_eff
              @settlement.inventory.add_item('H2O', produced, @settlement, {})
            end
          when 'mixed_volatiles'
            crust_volatiles.each do |volatile, percent|
              next if volatile.to_s.downcase == 'h2o'
              produced = input_amount * (percent.to_f / 100.0) * geosphere_eff
              @settlement.inventory.add_item(volatile, produced, @settlement, {})
            end
          when 'depleted_regolith'
            # Depleted regolith = input - all extracted volatiles
            total_extracted = crust_volatiles.values.map { |percent| input_amount * (percent.to_f / 100.0) * geosphere_eff }.sum
            produced = input_amount - total_extracted
            @settlement.inventory.add_item('depleted_regolith', produced, @settlement, {})
          end
        end
      end

      job.update!(status: :ready_to_claim)
    end
  end
end