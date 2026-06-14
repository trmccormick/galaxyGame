# frozen_string_literal: true

module Logistics
  class ExportManifestGenerator
    # Generate outbound manifest from source settlement (e.g., Luna) to destination (e.g., Earth)
    # carrying excess production with profit-maximizing cargo allocation.
    #
    # @param source_settlement [Settlement::BaseSettlement] Settlement exporting goods
    # @param destination_settlement [Settlement::BaseSettlement] Destination settlement importing goods
    # @return [Logistics::Manifest, nil] Created export manifest or nil if no viable cargo found
    def self.generate_return_manifest(source_settlement, destination_settlement)
      raise ArgumentError, 'Source settlement required' unless source_settlement.present?
      raise ArgumentError, 'Destination settlement required' unless destination_settlement.present?

      # Identify surplus resources beyond safety buffer at source settlement
      available_resources = identify_exportable_surplus(source_settlement)
      
      return nil if available_resources.empty?

      # Get AstroLift HLT cargo capacity constraints (50 tons per flight, standard container volume)
      manifest_capacity_kg = 50_000.0  # 50 metric tons in kg
      manifest_volume_m3 = calculate_available_container_space(source_settlement)

      # Optimize cargo load for maximum revenue while respecting physical constraints
      optimized_items = optimize_cargo_load(available_resources, manifest_capacity_kg, manifest_volume_m3)
      
      return nil if optimized_items.empty?

      # Create export manifest with profit-maximizing allocation
      create_export_manifest(source_settlement, destination_settlement, optimized_items)
    end

    # Identify surplus resources at settlement beyond local consumption needs and safety buffer.
    # Returns ranked list by profit potential per kg transported via HLT.
    #
    # @param settlement [Settlement::BaseSettlement] Settlement to analyze for exportable goods
    # @return [Array<Hash>] Array of { resource:, quantity_kg:, market_price_gcc:, total_value: } sorted by value density
    def self.identify_exportable_surplus(settlement)
      return [] unless settlement&.operational_data

      surplus = []
      
      # Get current stock levels from operational data
      inventory = settlement.operational_data['inventory'] || {}
      production_rates = settlement.operational_data['production_rates'] || {}
      consumption_targets = settlement.operational_data['consumption_targets'] || {}
      
      inventory.each do |resource_name, stock_data|
        # Handle both Hash format { quantity: 100.0 } and direct numeric values
        current_stock_kg = if stock_data.is_a?(Hash)
                             (stock_data[:quantity] || stock_data['quantity'] || 0).to_f
                           else
                             stock_data.to_f
                           end
        
        # Calculate target reserve based on consumption rate and safety buffer days
        daily_consumption = (consumption_targets[resource_name] || 0).to_f / 365.0  # Convert annual to daily
        safety_buffer_days = EconomicConfig.get('logistics.export.safety_buffer_days', 90)
        target_reserve_kg = daily_consumption * safety_buffer_days
        
        # Calculate exportable surplus (current stock minus target reserve)
        exportable_quantity = current_stock_kg - target_reserve_kg
        
        next if exportable_quantity <= 0

        # Get market price for this resource at destination context
        market_price_gcc_per_kg = Economics::MarketPriceService.get_current_market_price(
          resource_name,
          settlement_context: 'export'
        )
        
        next unless market_price_gcc_per_kg && market_price_gcc_per_kg > 0

        total_value = exportable_quantity * market_price_gcc_per_kg
        
        surplus << {
          resource: resource_name,
          quantity_kg: exportable_quantity.round(2),
          available_stock_kg: current_stock_kg.round(2),
          target_reserve_kg: target_reserve_kg.round(2),
          market_price_gcc_per_kg: market_price_gcc_per_kg.round(4),
          total_value: total_value.round(2),
          value_density: (total_value / [exportable_quantity, 1].max).round(4) # GCC per kg for sorting
        }
      end

      # Sort by value density (profit potential per kg transported via HLT) descending
      surplus.sort_by { |item| -item[:value_density] }
    rescue StandardError => e
      Rails.logger.error "ExportManifestGenerator.identify_exportable_surplus error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n") if Rails.env.development?
      []
    end

    # Maximize revenue per flight while respecting physical constraints and operational needs.
    # Uses greedy algorithm to maximize total_value = Σ(quantity_i × market_price_i)
    # Subject to: weight ≤ capacity, volume ≤ container space, each resource ≥ minimum shipment threshold
    #
    # @param available_resources [Array<Hash>] Resources from identify_exportable_surplus
    # @param manifest_capacity_kg [Float] Maximum cargo weight (AstroLift HLT = 50 tons)
    # @param manifest_volume_m3 [Float] Available container space in cubic meters
    # @return [Array<Hash>] Optimized items array for manifest creation
    def self.optimize_cargo_load(available_resources, manifest_capacity_kg, manifest_volume_m3)
      return [] if available_resources.empty?

      remaining_weight = manifest_capacity_kg.to_f
      remaining_volume = manifest_volume_m3.to_f
      
      optimized_items = []
      
      # Minimum shipment threshold (don't ship tiny quantities - not worth logistics overhead)
      minimum_shipment_threshold = EconomicConfig.get('logistics.export.minimum_shipment_kg', 10.0)

      available_resources.each do |resource|
        resource_name = resource[:resource]
        quantity_available = resource[:quantity_kg].to_f
        
        # Skip if below minimum shipment threshold
        next if quantity_available < minimum_shipment_threshold

        # Estimate volume per kg (simplified - should use material density from blueprint data)
        estimated_density_kg_per_m3 = estimate_material_density(resource_name)
        resource_volume_needed = quantity_available / [estimated_density_kg_per_m3, 1].max
        
        # Check if we have capacity for this entire shipment
        if remaining_weight >= quantity_available && remaining_volume >= resource_volume_needed
          # Take full quantity
          optimized_items << {
            resource: resource_name,
            quantity_kg: quantity_available.round(2),
            market_price_gcc_per_kg: resource[:market_price_gcc_per_kg],
            total_value: (quantity_available * resource[:market_price_gcc_per_kg]).round(2)
          }
          
          remaining_weight -= quantity_available
          remaining_volume -= resource_volume_needed
        elsif remaining_weight >= minimum_shipment_threshold && 
              remaining_volume >= (minimum_shipment_threshold / estimated_density_kg_per_m3)
          # Take partial shipment to fill remaining capacity greedily by value density
          max_quantity_by_weight = remaining_weight
          
          # Calculate volume-constrained quantity if applicable
          max_quantity_by_volume = remaining_volume * estimated_density_kg_per_m3
          constrained_quantity = [max_quantity_by_weight, max_quantity_by_volume].min.round(2)
          
          next if constrained_quantity < minimum_shipment_threshold

          optimized_items << {
            resource: resource_name,
            quantity_kg: constrained_quantity,
            market_price_gcc_per_kg: resource[:market_price_gcc_per_kg],
            total_value: (constrained_quantity * resource[:market_price_gcc_per_kg]).round(2)
          }
          
          remaining_weight -= constrained_quantity
          remaining_volume -= (constrained_quantity / estimated_density_kg_per_m3)

          # After partial fill, we've likely exhausted capacity - break out of loop
          break if remaining_weight < minimum_shipment_threshold || 
                  remaining_volume < (minimum_shipment_threshold / 1000.0)
        end
      end

      optimized_items.sort_by { |item| -item[:total_value] } # Sort by total value descending for display
    rescue StandardError => e
      Rails.logger.error "ExportManifestGenerator.optimize_cargo_load error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n") if Rails.env.development?
      []
    end

    private

    # Create export manifest with profit-maximizing resource allocation per AstroLift flight constraints.
    def self.create_export_manifest(source_settlement, destination_settlement, items)
      raise ArgumentError, 'Items list cannot be empty' if items.nil? || items.empty?

      # Calculate totals for the optimized cargo load
      total_weight_kg = items.sum { |item| item[:quantity_kg].to_f }.round(2)
      estimated_revenue_gcc = items.sum { |item| item[:total_value].to_f }.round(2)

      # Create manifest with export-specific fields
      Logistics::Manifest.create!(
        manifest_id: SecureRandom.uuid,
        source_settlement: source_settlement,
        destination_settlement: destination_settlement,
        items: items.map do |item|
          {
            resource: item[:resource],
            quantity_kg: item[:quantity_kg],
            category: determine_resource_category(item[:resource]),
            market_price_gcc_per_kg: item[:market_price_gcc_per_kg],
            total_value: item[:total_value]
          }
        end,
        manifest_type: 1,  # Distinguish from import manifests (Phase 2/3) - export = 1
        total_weight_kg: total_weight_kg,
        estimated_revenue_gcc: estimated_revenue_gcc,
        status: :pending  # Export needs approval before shipment - use existing enum value
      )
    rescue StandardError => e
      Rails.logger.error "ExportManifestGenerator.create_export_manifest error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n") if Rails.env.development?
      nil
    end

    # Determine resource category for manifest organization (stub - should use blueprint system)
    def self.determine_resource_category(resource_name)
      case resource_name.downcase
      when /helium|he-3|helium-3/
        :rare_isotope  # High-value export from lunar regolith processing
      when /regolith|rare earth|mineral|ore/
        :raw_material
      when /component|circuit|board|panel/
        :manufactured_good
      when /scientific sample|sample|research/
        :research_material
      else
        :general_cargo  # Default category for unknown resources
      end
    end

    # Estimate material density in kg/m³ (simplified - should use blueprint data)
    def self.estimate_material_density(resource_name)
      case resource_name.downcase
      when /regolith|soil|dirt/ then 1500.0  # Loose regolith ~1.5 g/cm³
      when /helium|h3|he-3|gas/ then 0.1786   # Helium gas at STP (very low density)
      when /steel|iron|metal/ then 7850.0    # Steel/Iron ~7.8 g/cm³
      when /water|liquid|cryo/ then 1000.0   # Water = 1 g/cm³
      else 2000.0                             # Default assumption for bulk materials
      end
    rescue StandardError => e
      Rails.logger.warn "Could not estimate density for #{resource_name}, using default: #{e.message}"
      2000.0
    end

    # Calculate available container space at settlement (simplified - should query storage facilities)
    def self.calculate_available_container_space(settlement)
      # Default to standard AstroLift HLT cargo bay volume if not specified in operational data
      default_volume_m3 = 125.0  # ~50 tons of bulk material fits in ~125 m³
      
      return default_volume_m3 unless settlement&.operational_data

      storage_capacity = settlement.operational_data.dig('storage', 'available_container_space') || 
                        settlement.operational_data['container_space']
      
      storage_capacity.to_f > 0 ? storage_capacity : default_volume_m3
    end
  end
end
