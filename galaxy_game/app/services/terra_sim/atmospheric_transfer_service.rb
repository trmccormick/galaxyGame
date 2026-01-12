module TerraSim
  class AtmosphericTransferService
    # Constants for transfer modes
    TRANSFER_MODES = {
      raw: 'raw',
      selective: 'selective',
      processed: 'processed'
    }
    
    attr_reader :results
    
    def initialize(source_body, target_body, options = {})
      @source = source_body
      @target = target_body
      @options = options
      @mode = options[:mode] || TRANSFER_MODES[:raw]
      @logger = options[:logger]
      @settings = options[:settings] || {}
      
      # Initialize results tracking
      @results = {
        gases_extracted: {},
        gases_delivered: {},
        gases_produced: {},
        efficiency: 0.0,
        success: false,
        messages: []
      }
    end
    
    # Main public interface for atmospheric transfer
    def transfer_atmosphere(transfer_params)
      # Validate parameters
      validate_transfer_params(transfer_params)
      
      # Clear previous results
      reset_results
      
      # Perform the appropriate transfer type
      case @mode.to_s
      when TRANSFER_MODES[:raw]
        perform_raw_transfer(transfer_params)
      when TRANSFER_MODES[:selective]
        perform_selective_transfer(transfer_params)
      when TRANSFER_MODES[:processed]
        perform_processed_transfer(transfer_params)
      else
        log_error("Unknown transfer mode: #{@mode}")
        return @results
      end
      
      # Calculate efficiency
      calculate_efficiency
      
      # Update atmospheres in database
      update_atmospheres
      
      @results[:success] = true
      @results
    end
    
    private
    
    def reset_results
      @results = {
        gases_extracted: {},
        gases_delivered: {},
        gases_produced: {},
        efficiency: 0.0,
        success: false,
        messages: []
      }
    end
    
    def validate_transfer_params(params)
      # Check for required parameters based on mode
      case @mode.to_s
      when TRANSFER_MODES[:raw]
        unless params[:capacity].present?
          raise ArgumentError, "Raw transfer requires :capacity parameter"
        end
      when TRANSFER_MODES[:selective]
        unless params[:gases].present? && params[:gases].is_a?(Hash)
          raise ArgumentError, "Selective transfer requires :gases parameter as a hash"
        end
      when TRANSFER_MODES[:processed]
        unless params[:capacity].present?
          raise ArgumentError, "Processed transfer requires :capacity parameter"
        end
      end
      
      # Verify source and target have atmospheres
      unless @source.atmosphere.present?
        raise ArgumentError, "Source body #{@source.name} has no atmosphere"
      end
      
      unless @target.atmosphere.present?
        raise ArgumentError, "Target body #{@target.name} has no atmosphere"
      end
    end
    
    # Raw atmospheric transfer (proportional extraction of all gases)
    def perform_raw_transfer(params)
      # Determine how much we can extract (limited by capacity and source atmosphere)
      capacity = params[:capacity].to_f
      
      # Apply source-specific extraction limits
      # Venus: No percentage limit - goal is to reduce from ~90 bar to ~1 bar (remove ~99%)
      #        Only limited by cycler capacity
      # Titan: 5% limit to preserve atmosphere while extracting CH4
      # Others: 20% default for safety
      extraction_limit = case @source.name.downcase
      when 'titan'
        0.05  # 5% limit to preserve Titan while extracting CH4 for early greenhouse warming
      when 'venus'
        Float::INFINITY  # No limit - cycler capacity is the only constraint
      else
        0.20  # 20% default limit for other bodies
      end
      
      max_extractable = extraction_limit == Float::INFINITY ? 
        @source.atmosphere.total_atmospheric_mass : 
        @source.atmosphere.total_atmospheric_mass * extraction_limit
      extracted_mass = [capacity, max_extractable].min
      
      log_info("Raw transfer: Extracting #{format_mass(extracted_mass)} total gas from #{@source.name}")
      
      # Extract gases proportionally and deliver them
      @source.atmosphere.gases.each do |gas|
        # Calculate proportional mass based on percentage
        gas_mass_to_extract = extracted_mass * (gas.percentage / 100.0)
        # Safeguard: skip zero/negative amounts
        next if gas_mass_to_extract.nil? || gas_mass_to_extract <= 0

        # Apply transport efficiency (98% delivery)
        transport_efficiency = params[:efficiency] || 0.98
        gas_mass_delivered = gas_mass_to_extract * transport_efficiency
        next if gas_mass_delivered.nil? || gas_mass_delivered <= 0

        # Extract from source
        @source.atmosphere.remove_gas(gas.name, gas_mass_to_extract)

        # Record in results
        @results[:gases_extracted][gas.name] = gas_mass_to_extract

        # Deliver to target
        @target.atmosphere.add_gas(gas.name, gas_mass_delivered)

        # Record in results
        @results[:gases_delivered][gas.name] = gas_mass_delivered

        log_info("  - #{gas.name}: Extracted #{format_mass(gas_mass_to_extract)}, delivered #{format_mass(gas_mass_delivered)}")
      end
    end
    
    # Selective transfer of specific gases
    def perform_selective_transfer(params)
      gases_to_transfer = params[:gases]
      
      gases_to_transfer.each do |gas_name, requested_amount|
        # Find the gas in the source atmosphere
        gas = @source.atmosphere.gases.find_by(name: gas_name)
        next unless gas

        # Determine how much we can extract
        # Apply source-specific extraction limits
        extraction_limit = case @source.name.downcase
        when 'titan'
          0.05  # 5% limit to preserve Titan while extracting CH4
        when 'venus'
          Float::INFINITY  # No limit - cycler capacity is the only constraint
        else
          0.20  # 20% default limit
        end
        
        max_extractable = extraction_limit == Float::INFINITY ? 
          gas.mass : 
          gas.mass * extraction_limit
        capacity_for_gas = params[:capacity_per_gas] || requested_amount
        gas_mass_to_extract = [requested_amount, max_extractable, capacity_for_gas].min
        next if gas_mass_to_extract.nil? || gas_mass_to_extract <= 0

        # Apply transport efficiency
        transport_efficiency = params[:efficiency] || 0.98
        gas_mass_delivered = gas_mass_to_extract * transport_efficiency
        next if gas_mass_delivered.nil? || gas_mass_delivered <= 0

        log_info("Selective transfer: #{gas_name} - Extracting #{format_mass(gas_mass_to_extract)}")

        # Extract from source
        @source.atmosphere.remove_gas(gas_name, gas_mass_to_extract)

        # Record in results
        @results[:gases_extracted][gas_name] = gas_mass_to_extract

        # Deliver to target
        @target.atmosphere.add_gas(gas_name, gas_mass_delivered)

        # Record in results
        @results[:gases_delivered][gas_name] = gas_mass_delivered

        log_info("  - Delivered #{format_mass(gas_mass_delivered)} to #{@target.name}")
      end
    end
    
    # Processed transfer with MOXIE-style CO2 processing
    def perform_processed_transfer(params)
      # Get source gases
      co2 = @source.atmosphere.gases.find_by(name: 'CO2')
      n2 = @source.atmosphere.gases.find_by(name: 'N2')
      
      unless co2 && n2
        log_error("Processed transfer requires CO2 and N2 in source atmosphere")
        return
      end
      
      # Determine capacities
      total_capacity = params[:capacity].to_f
      co2_ratio = params[:co2_ratio] || 0.8
      n2_ratio = params[:n2_ratio] || 0.2
      
      co2_capacity = total_capacity * co2_ratio
      n2_capacity = total_capacity * n2_ratio
      
      # Determine how much we can extract
      max_co2_extractable = co2.mass * 0.005
      max_n2_extractable = n2.mass * 0.005
      
      co2_mass_to_extract = [co2_capacity, max_co2_extractable].min
      n2_mass_to_extract = [n2_capacity, max_n2_extractable].min
      # Safeguard: skip zero/negative amounts
      co2_mass_to_extract = 0 if co2_mass_to_extract.nil? || co2_mass_to_extract <= 0
      n2_mass_to_extract = 0 if n2_mass_to_extract.nil? || n2_mass_to_extract <= 0

      log_info("Processed transfer: CO2 #{format_mass(co2_mass_to_extract)}, N2 #{format_mass(n2_mass_to_extract)}")

      # Extract gases from source
      @source.atmosphere.remove_gas('CO2', co2_mass_to_extract) if co2_mass_to_extract > 0
      @source.atmosphere.remove_gas('N2', n2_mass_to_extract) if n2_mass_to_extract > 0

      # Record extractions
      @results[:gases_extracted]['CO2'] = co2_mass_to_extract
      @results[:gases_extracted]['N2'] = n2_mass_to_extract

      # Process CO2 to O2 and CO using MOXIE reaction
      # CO2 -> CO + 1/2 O2
      processing_efficiency = params[:processing_efficiency] || 0.95
      molar_o2_ratio = 16.0 / 44.0  # Oxygen mass / CO2 mass
      molar_co_ratio = 28.0 / 44.0  # CO mass / CO2 mass

      o2_mass_produced = co2_mass_to_extract * molar_o2_ratio * processing_efficiency
      co_mass_produced = co2_mass_to_extract * molar_co_ratio * processing_efficiency

      log_info("  - MOXIE output: O2 #{format_mass(o2_mass_produced)}, CO #{format_mass(co_mass_produced)}")

      # Apply transport efficiency
      transport_efficiency = params[:efficiency] || 0.98
      n2_mass_delivered = n2_mass_to_extract * transport_efficiency
      o2_mass_delivered = o2_mass_produced * transport_efficiency
      co_mass_delivered = co_mass_produced * transport_efficiency

      # Deliver gases
      # Return some CO to source planet
      @source.atmosphere.add_gas('CO', co_mass_delivered) if co_mass_delivered > 0

      # Send O2 and N2 to target planet
      add_gas_with_fallback_molar_mass(@target, 'O2', o2_mass_delivered, 32.0) if o2_mass_delivered > 0
      add_gas_with_fallback_molar_mass(@target, 'N2', n2_mass_delivered, 28.0) if n2_mass_delivered > 0

      # Record deliveries and production
      @results[:gases_delivered]['O2'] = o2_mass_delivered
      @results[:gases_delivered]['N2'] = n2_mass_delivered
      @results[:gases_delivered]['CO'] = co_mass_delivered

      @results[:gases_produced]['O2'] = o2_mass_produced
      @results[:gases_produced]['CO'] = co_mass_produced

      log_info("  - Delivered to #{@target.name}: O2 #{format_mass(o2_mass_delivered)}, N2 #{format_mass(n2_mass_delivered)}")
      log_info("  - Returned to #{@source.name}: CO #{format_mass(co_mass_delivered)}")
    end
    
    # Helper to add gas with fallback molar mass if not defined
    def add_gas_with_fallback_molar_mass(planet, gas_name, amount, fallback_molar_mass)
      begin
        planet.atmosphere.add_gas(gas_name, amount)
      rescue => e
        # If gas exists but has no molar mass, set it and retry
        gas = planet.atmosphere.gases.find_by(name: gas_name)
        if gas && gas.molar_mass.nil?
          gas.update!(molar_mass: fallback_molar_mass)
          retry
        else
          log_error("Failed to add gas #{gas_name}: #{e.message}")
          raise e
        end
      end
    end
    
    # Calculate overall efficiency of the transfer
    def calculate_efficiency
      total_extracted = @results[:gases_extracted].values.sum
      total_delivered = @results[:gases_delivered].values.sum
      
      @results[:efficiency] = total_extracted > 0 ? (total_delivered / total_extracted) : 0
    end
    
    # Update atmosphere pressures after transfer
    def update_atmospheres
      @source.atmosphere.update_pressure_from_mass!
      @target.atmosphere.update_pressure_from_mass!
    end
    
    # Helper for mass formatting
    def format_mass(mass)
      if mass >= 1.0e18
        "#{(mass / 1.0e18).round(2)} Et"
      elsif mass >= 1.0e15
        "#{(mass / 1.0e15).round(2)} Pt"
      elsif mass >= 1.0e12
        "#{(mass / 1.0e12).round(2)} Tt"
      elsif mass >= 1.0e9
        "#{(mass / 1.0e9).round(2)} Gt"
      elsif mass >= 1.0e6
        "#{(mass / 1.0e6).round(2)} Mt"
      elsif mass >= 1.0e3
        "#{(mass / 1.0e3).round(2)} kt"
      else
        "#{mass.round(2)} kg"
      end
    end
    
    # Logging helpers
    def log_info(message)
      @results[:messages] << message
      @logger.call(message) if @logger
    end
    
    def log_error(message)
      @results[:messages] << "ERROR: #{message}"
      @logger.call("ERROR: #{message}") if @logger
      Rails.logger.error(message)
    end

    def perform_transfer(source_planet, target_planet, gas_name, amount)
      # Extract the gas from source
      source_planet.atmosphere.remove_gas(gas_name, amount)
      
      # Delivery efficiency calculation
      delivered_amount = amount * 0.98  # 2% lost in transit
      
      # Add to target planet
      target_planet.atmosphere.add_gas(gas_name, delivered_amount)
      
      # The materials are automatically updated by the add_gas and remove_gas methods
      
      # Return the actual amount delivered
      delivered_amount
    end
  end
end