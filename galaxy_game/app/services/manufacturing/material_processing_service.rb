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
      if input_material == 'raw_regolith' && !@settlement.inventory.has_item?('raw_regolith', input_amount)
        return { error: "Insufficient raw regolith" }
      elsif input_material == 'processed_regolith' && !@settlement.inventory.has_item?('processed_regolith', input_amount)
        return { error: "Insufficient processed regolith" }
      end
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
      unless @settlement.inventory.has_item?(input_material, input_amount)
        return { error: "Insufficient #{input_material}" }
      end
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
      processed_regolith = job.input_amount * 0.995
      @settlement.inventory.remove_item('raw_regolith', job.input_amount, @settlement, {})
      @settlement.inventory.add_item('processed_regolith', processed_regolith, @settlement, {})
      job.complete!
    end

    def complete_volatiles_extraction(job)
      @settlement.inventory.remove_item('processed_regolith', job.input_amount, @settlement, {})
      # Mars baseline: hydrogen = 0.03 * (per 5.0 input), others = 0.01 * (per 5.0 input)
      @settlement.inventory.add_item('hydrogen', job.input_amount * 0.006, @settlement, {})
      %w[carbon_monoxide helium neon].each do |gas|
        @settlement.inventory.add_item(gas, job.input_amount * 0.002, @settlement, {})
      end
      job.complete!
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