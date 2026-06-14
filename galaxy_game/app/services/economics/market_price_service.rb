# frozen_string_literal: true

module Economics
  class MarketPriceService
    # Get current market price for a resource type using existing market infrastructure.
    # Uses EAP (Earth Anchor Price) as ceiling and Earth spot + transport cost as floor.
    # Does NOT require live simulation data - bootstrapped from static sources only.
    #
    # @param resource_type [String] Resource name/identifier (e.g., "Helium-3", "Steel")
    # @param settlement_context [Hash, String] Context for pricing ('import', 'export', or hash with details)
    # @return [Float, nil] Price in GCC per kg, or nil if price cannot be determined
    def self.get_current_market_price(resource_type, settlement_context = {})
      return nil unless resource_type.present?

      context_hash = settlement_context.is_a?(Hash) ? settlement_context : { purpose: settlement_context }
      
      # Load material data for EAP calculation (price ceiling from blueprint/recipe data)
      eap_ceiling = calculate_eap_price(resource_type)
      
      # Calculate Earth spot price + transportation_cost_per_kg as floor
      transport_floor = calculate_transport_floored_price(resource_type, context_hash)

      return nil unless eap_ceiling || transport_floor
      
      # Return price within EAP ceiling / transport floor range
      if eap_ceiling && transport_floor
        # Use midpoint between floor and ceiling for bootstrap pricing (no live simulation yet)
        # TODO PHASE 6+: Supply/demand modifiers based on destination settlement stock levels
        return ((eap_ceiling + transport_floor) / 2.0).round(4)
      elsif eap_ceiling
        return eap_ceiling.round(4)
      else
        return transport_floor.round(4)
      end
    rescue StandardError => e
      Rails.logger.error "MarketPriceService.get_current_market_price error for #{resource_type}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n") if Rails.env.development?
      nil
    end

    # Calculate trade balance between import costs and export revenues.
    # Returns net GCC flow direction (positive = settlement earning more than spending).
    #
    # @param import_manifests [Array<Logistics::Manifest>] Import manifests for the period
    # @param export_manifests [Array<Logistics::Manifest>] Export manifests for the period
    # @return [Hash] Trade balance report with costs, revenues, and net flow direction
    def self.calculate_trade_balance(import_manifests = [], export_manifests = [])
      import_costs = calculate_total_import_costs(import_manifests)
      export_revenues = calculate_total_export_revenues(export_manifests)

      {
        total_import_costs_gcc: import_costs.round(2),
        total_export_revenues_gcc: export_revenues.round(2),
        net_trade_balance_gcc: (export_revenues - import_costs).round(2),  # Positive = surplus, Negative = deficit
        trade_ratio: import_costs > 0 ? ((export_revenues / import_costs.to_f) * 100).round(2) : Float::INFINITY,
        flow_direction: export_revenues >= import_costs ? 'surplus' : 'deficit',
        recommendations: generate_trade_recommendations(import_manifests, export_manifests)
      }
    rescue StandardError => e
      Rails.logger.error "MarketPriceService.calculate_trade_balance error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n") if Rails.env.development?
      
      {
        total_import_costs_gcc: 0.0,
        total_export_revenues_gcc: 0.0,
        net_trade_balance_gcc: 0.0,
        trade_ratio: nil,
        flow_direction: 'unknown',
        recommendations: ['Error calculating trade balance']
      }
    end

    # Get comprehensive trade balance report for a settlement over time window.
    #
    # @param settlement [Settlement::BaseSettlement] Settlement to analyze
    # @param time_window_days [Integer] Number of days to look back (default: 90)
    # @return [Hash] Trade balance report with period details and recommendations
    def self.get_trade_balance_report(settlement, time_window_days = 90)
      return nil unless settlement.present?

      period_start_date = time_window_days.days.ago.to_date
      
      # Get import manifests (settlement as destination - receiving goods from Earth/other settlements)
      import_manifests = Logistics::Manifest.where(
        destination_settlement: settlement,
        created_at: period_start_date..Time.now
      ).to_a

      # Get export manifests (settlement as source - sending goods to Earth/other settlements)  
      export_manifests = Logistics::Manifest.joins(:items).where(
        source_settlement: settlement,
        manifest_type: :export,  # Only count explicit exports, not internal transfers
        created_at: period_start_date..Time.now
      ).to_a

      balance_data = calculate_trade_balance(import_manifests, export_manifests)

      {
        settlement_name: settlement.name,
        period_start_date: period_start_date,
        period_end_date: Date.today,
        total_import_costs_gcc: balance_data[:total_import_costs_gcc],
        total_export_revenues_gcc: balance_data[:total_export_revenues_gcc],
        net_trade_balance_gcc: balance_data[:net_trade_balance_gcc],
        trade_ratio: balance_data[:trade_ratio],
        flow_direction: balance_data[:flow_direction],
        top_export_resources: identify_top_exports(export_manifests),
        recommendations: balance_data[:recommendations]
      }
    rescue StandardError => e
      Rails.logger.error "MarketPriceService.get_trade_balance_report error for #{settlement&.name}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n") if Rails.env.development?
      
      {
        settlement_name: settlement&.name,
        period_start_date: time_window_days.days.ago.to_date,
        period_end_date: Date.today,
        total_import_costs_gcc: 0.0,
        total_export_revenues_gcc: 0.0,
        net_trade_balance_gcc: 0.0,
        trade_ratio: nil,
        flow_direction: 'unknown',
        top_export_resources: [],
        recommendations: ['Error generating report']
      }
    end

    private

    # Calculate EAP (Earth Anchor Price) as price ceiling from blueprint data.
    def self.calculate_eap_price(resource_type)
      material_data = load_material_data(resource_type)
      
      return nil unless material_data.present?

      Tier1PriceModeler.new(
        material_data,
        destination: 'luna',  # Default to Luna as export destination context
        source: 'earth'       # Earth is the baseline for EAP calculation
      ).calculate_eap
    rescue StandardError => e
      Rails.logger.warn "Could not calculate EAP for #{resource_type}: #{e.message}"
      nil
    end

    # Calculate transport-floored price using market_settings.transportation_cost_per_kg.
    def self.calculate_transport_floored_price(resource_type, context_hash)
      # Get transportation cost from market settings (seeded value required - see task file)
      transport_setting = Market::Settings.first
      
      return nil unless transport_setting && transport_setting.transportation_cost_per_kg.to_f > 0

      transport_cost_per_kg = transport_setting.transportation_cost_per_kg.to_f
      
      # Get Earth spot price from material data or EconomicConfig fallbacks
      earth_spot_price_gcc = get_earth_spot_price(resource_type)
      
      return nil unless earth_spot_price_gcc && earth_spot_price_gcc > 0

      # Floor price = Earth spot + transport cost (minimum viable export price)
      floor_price = earth_spot_price_gcc + transport_cost_per_kg
      
      # Apply premium for high-value exports like He-3 from Luna
      if context_hash[:purpose] == 'export' && resource_type.downcase.include?('helium') || 
         resource_type.downcase.include?('he-3')
        helium_premium = EconomicConfig.get('pricing.export.helium_3_premium', 1.5) # 50% premium for He-3 exports
        floor_price *= helium_premium
      end

      floor_price.round(4)
    rescue StandardError => e
      Rails.logger.warn "Could not calculate transport-floored price for #{resource_type}: #{e.message}"
      nil
    end

    # Get Earth spot price in GCC (not USD - already converted to game currency).
    def self.get_earth_spot_price(resource_type)
      material_data = load_material_data(resource_type)
      
      return EconomicConfig.earth_spot_price(resource_type) unless material_data
      
      # Try multiple paths for earth pricing from v1.4+ blueprint format
      price = material_data.dig('pricing', 'earth_usd', 'base_price_per_kg') || 
              material_data.dig('pricing', 'earth', 'base_price_per_kg') ||
              material_data['earth_spot_price_usd_per_kg']
              
      return nil unless price
      
      # Convert USD to GCC using peg from EconomicConfig
      usd_to_gcc_peg = EconomicConfig.usd_to_gcc_peg
      (price.to_f * usd_to_gcc_peg).round(4)
    rescue StandardError => e
      Rails.logger.warn "Could not get Earth spot price for #{resource_type}: #{e.message}"
      
      # Fallback to config-based pricing
      EconomicConfig.earth_spot_price(resource_type)
    end

    # Load material data from JSON files or blueprint system.
    def self.load_material_data(resource_type)
      return nil unless resource_type.present?

      normalized_id = resource_type.downcase.gsub(/\s+/, '_')
      
      # Try to load from materials directory (v1.4+ format preferred)
      materials_dir = Rails.root.join('data', 'materials')
      
      if Dir.exist?(materials_dir)
        material_file = Dir.glob(File.join(materials_dir, '**/*.json')).find do |file|
          File.basename(file, '.json').downcase.include?(normalized_id) || 
          file.downcase.include?(normalized_id)
        end
        
        return JSON.parse(File.read(material_file)) if material_file && File.exist?(material_file)
      end

      # Try json-data directory (legacy format)
      json_data_dir = Rails.root.parent.join('data', 'json-data')  # galaxyGame/data/json-data
      
      if Dir.exist?(json_data_dir)
        material_files = [
          File.join(json_data_dir, 'materials.json'),
          File.join(json_data_dir, 'resources.json'),
          File.join(json_data_dir, 'blueprints.json')
        ]

        material_files.each do |file|
          next unless File.exist?(file)
          
          data = JSON.parse(File.read(file))
          
          # Try to find resource in various array structures
          if data.is_a?(Array)
            return data.find { |item| item['name']&.downcase&.include?(normalized_id) || 
                                       item['id']&.to_s&.downcase&.include?(normalized_id) }
          elsif data.is_a?(Hash) && data['materials'].is_a?(Array)
            return data['materials'].find { |item| item['name']&.downcase&.include?(normalized_id) || 
                                                    item['id']&.to_s&.downcase&.include?(normalized_id) }
          end
        end
      end

      nil  # Material not found in any data source
    rescue StandardError => e
      Rails.logger.warn "Could not load material data for #{resource_type}: #{e.message}"
      nil
    end

    # Calculate total import costs from manifests.
    def self.calculate_total_import_costs(import_manifests)
      return 0.0 if import_manifests.empty?

      import_manifests.sum do |manifest|
        manifest.total_cost.to_f || 
          (manifest.items&.sum { |item| item[:quantity].to_f * item[:unit_cost].to_f } || 0).to_f
      end.round(2)
    rescue StandardError => e
      Rails.logger.warn "Could not calculate import costs: #{e.message}"
      0.0
    end

    # Calculate total export revenues from manifests.
    def self.calculate_total_export_revenues(export_manifests)
      return 0.0 if export_manifests.empty?

      export_manifests.sum do |manifest|
        manifest.estimated_revenue_gcc.to_f || 
          (manifest.items&.sum { |item| item[:quantity_kg].to_f * item[:market_price_gcc_per_kg].to_f } || 0).to_f
      end.round(2)
    rescue StandardError => e
      Rails.logger.warn "Could not calculate export revenues: #{e.message}"
      0.0
    end

    # Identify top exporting resources by revenue contribution.
    def self.identify_top_exports(export_manifests, limit = 5)
      return [] if export_manifests.empty?

      resource_revenues = Hash.new { |hash, key| hash[key] = 0.0 }
      
      export_manifests.each do |manifest|
        next unless manifest.items.is_a?(Array)
        
        manifest.items.each do |item|
          quantity_kg = item[:quantity_kg].to_f || 
                        (item.dig('quantity_kg')&.to_f || 0).to_f || 
                        item[:quantity].to_f # Fallback to legacy 'quantity' field
          
          market_price_gcc_per_kg = item[:market_price_gcc_per_kg].to_f || 
                                    (item.dig('market_price_gcc_per_kg')&.to_f || 0).to_f

          resource_revenues[item[:resource]] += quantity_kg * market_price_gcc_per_kg
        end
      rescue StandardError => e
        Rails.logger.warn "Could not process manifest items: #{e.message}"
        next
      end

      # Sort by revenue descending and take top N
      resource_revenues.sort_by { |_, value| -value }.first(limit).map do |resource, revenue|
        {
          resource_name: resource,
          total_revenue_gcc: revenue.round(2)
        }
      end
    rescue StandardError => e
      Rails.logger.warn "Could not identify top exports: #{e.message}"
      []
    end

    # Generate trade recommendations based on balance analysis.
    def self.generate_trade_recommendations(import_manifests, export_manifests)
      recommendations = []

      import_costs = calculate_total_import_costs(import_manifests)
      export_revenues = calculate_total_export_revenues(export_manifests)

      if import_costs > 0 && (export_revenues / import_costs.to_f) < 0.5
        recommendations << "Export revenue is less than 50% of import costs - consider increasing high-value exports"
      end
      
      if export_manifests.empty? && !import_manifests.empty?
        recommendations << "No export activity detected - Luna settlement only importing, not exporting return cargo"
      end

      # Check for He-3 specifically (high-value lunar resource)
      helium_exports = identify_top_exports(export_manifests).find { |r| r[:resource_name].downcase.include?('helium') }
      
      if !helium_exports && import_costs > 10_000.0 # Significant imports but no He-3 exports
        recommendations << "Helium-3 not detected in export manifests - consider prioritizing this high-value lunar resource"
      end

      recommendations.empty? ? ['Trade balance appears healthy'] : recommendations
    rescue StandardError => e
      Rails.logger.warn "Could not generate trade recommendations: #{e.message}"
      []
    end
  end
end
