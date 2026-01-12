# app/services/resource_tracking_service.rb
# Service for tracking AI resource usage and procurement methods
# Helps tune the simulation and balance ISRU vs imports vs player fulfillment

class ResourceTrackingService
  # Track resource procurement for AI missions
  def self.track_procurement(settlement, material, quantity, method, context = {})
    # Sanitize context to only include JSON-serializable values
    sanitized_context = {
      purpose: context[:purpose],
      mission_id: context[:mission_id],
      task_type: context[:task_type],
      requester_name: context[:requester]&.name,
      requester_type: context[:requester]&.class&.name
    }.compact

    entry = {
      timestamp: Time.current.iso8601,
      settlement_id: settlement.id,
      settlement_name: settlement.name,
      material: material,
      quantity: quantity,
      procurement_method: method,
      context: sanitized_context,
      mission_id: context[:mission_id],
      task_type: context[:task_type]
    }

    # Log to Rails logger
    Rails.logger.info "[ResourceTracking] #{settlement.name}: #{quantity} #{material} via #{method} (#{context[:purpose] || 'unknown'})"

    # Store in settlement operational data for analysis
    track_settlement_procurement(settlement, entry)

    entry
  end

  # Track procurement in settlement operational data
  def self.track_settlement_procurement(settlement, entry)
    settlement.operational_data ||= {}
    settlement.operational_data['resource_tracking'] ||= {}
    settlement.operational_data['resource_tracking']['procurement'] ||= []
    settlement.operational_data['resource_tracking']['procurement'] << entry

    # Keep only last 1000 procurement entries
    procurement_log = settlement.operational_data['resource_tracking']['procurement']
    if procurement_log.length > 1000
      procurement_log.shift(procurement_log.length - 1000)
    end

    settlement.save!
  end

  # Track revenue from exports and sales (lunar samples, LOX fuel, etc.)
  def self.track_revenue(settlement, material, quantity, revenue_usd, buyer, context = {})
    # Sanitize context
    sanitized_context = {
      purpose: context[:purpose],
      mission_id: context[:mission_id],
      transaction_type: context[:transaction_type] || 'export',
      buyer_name: buyer,
      unit_price_usd: context[:unit_price_usd]
    }.compact

    entry = {
      timestamp: Time.current.iso8601,
      settlement_id: settlement.id,
      settlement_name: settlement.name,
      material: material,
      quantity: quantity,
      revenue_usd: revenue_usd,
      buyer: buyer,
      context: sanitized_context,
      mission_id: context[:mission_id]
    }

    # Log to Rails logger
    Rails.logger.info "[RevenueTracking] #{settlement.name}: Sold #{quantity} #{material} to #{buyer} for $#{revenue_usd} (#{context[:purpose] || 'export'})"

    # Store in settlement operational data
    track_settlement_revenue(settlement, entry)

    entry
  end

  # Track settlement resource inventory over time
  def self.track_inventory_snapshot(settlement)
    # Get procurement history to determine sourcing
    procurement_data = settlement.operational_data&.dig('resource_tracking', 'procurement') || []
    procurement_by_material = procurement_data.group_by { |p| p['material'] }
    
    inventory_data = settlement.inventory.items.map do |item|
      # Determine procurement method and source for this material
      material_name = item.name.downcase
      
      # Intelligent procurement method determination
      procurement_method, source_body = determine_procurement_method(settlement, material_name, procurement_by_material)
      
      {
        material: item.name,
        quantity: item.amount,
        category: categorize_material(item.name),
        procurement_method: procurement_method,
        source_body: source_body
      }
    end

    snapshot = {
      timestamp: Time.current.iso8601,
      settlement_id: settlement.id,
      total_items: inventory_data.length,
      inventory: inventory_data,
      total_value: calculate_inventory_value(inventory_data)
    }

    # Store snapshot in settlement operational data
    store_inventory_snapshot(settlement, snapshot)

    snapshot
  end

  # Get resource usage statistics for tuning
  def self.get_resource_stats(settlement, time_range = 24.hours)
    start_time = Time.current - time_range

    procurement_data = settlement.operational_data&.dig('resource_tracking', 'procurement') || []
    recent_procurement = procurement_data.select { |entry| Time.parse(entry['timestamp']) > start_time }

    revenue_data = settlement.operational_data&.dig('resource_tracking', 'revenue') || []
    recent_revenue = revenue_data.select { |entry| Time.parse(entry['timestamp']) > start_time }

    inventory_snapshots = settlement.operational_data&.dig('resource_tracking', 'inventory_snapshots') || []
    recent_snapshots = inventory_snapshots.select { |snap| Time.parse(snap['timestamp']) > start_time }

    {
      procurement_summary: summarize_procurement(recent_procurement),
      revenue_summary: summarize_revenue(recent_revenue),
      inventory_trends: analyze_inventory_trends(recent_snapshots),
      efficiency_metrics: calculate_efficiency_metrics(recent_procurement, recent_snapshots.last, recent_revenue)
    }
  end

  private

  def self.track_settlement_revenue(settlement, entry)
    settlement.operational_data ||= {}
    settlement.operational_data['resource_tracking'] ||= {}
    settlement.operational_data['resource_tracking']['revenue'] ||= []
    settlement.operational_data['resource_tracking']['revenue'] << entry

    # Keep only last 1000 revenue entries
    revenue_log = settlement.operational_data['resource_tracking']['revenue']
    if revenue_log.length > 1000
      revenue_log.shift(revenue_log.length - 1000)
    end

    settlement.save!
  end

  def self.store_inventory_snapshot(settlement, snapshot)
    settlement.operational_data ||= {}
    settlement.operational_data['resource_tracking'] ||= {}
    settlement.operational_data['resource_tracking']['inventory_snapshots'] ||= []
    settlement.operational_data['resource_tracking']['inventory_snapshots'] << snapshot

    # Keep only last 50 snapshots
    snapshots = settlement.operational_data['resource_tracking']['inventory_snapshots']
    if snapshots.length > 50
      snapshots.shift(snapshots.length - 50)
    end

    settlement.save!
  end

  def self.determine_procurement_method(settlement, material_name, procurement_by_material)
    # Check if we have explicit procurement history for this material
    material_procurement = procurement_by_material[material_name]&.last
    if material_procurement
      procurement_method = material_procurement['procurement_method']
      source_body = material_procurement.dig('context', 'source_body') || settlement.location&.name || 'unknown'
      return [procurement_method, source_body]
    end

    # Intelligent determination based on settlement capabilities and location
    settlement_location = settlement.location
    celestial_body_name = settlement_location&.celestial_body&.name&.downcase || ''
    is_lunar_settlement = celestial_body_name.include?('luna') || celestial_body_name.include?('moon')

    # Check if this is an assembled/manufactured item vs raw material
    is_assembled_item = material_name.include?('unassembled') || material_name.include?('printed') || material_name.include?('manufactured')
    
    if is_assembled_item
      # Assembled items are manufactured locally
      return ['manufactured', settlement_location&.name || 'settlement']
    end

    case material_name
    when /regolith|soil/i
      # Regolith is always local if on a planetary body
      is_lunar_settlement ? ['isru', settlement.location&.name || 'luna'] : ['ai_autofulfill', 'earth']
    
    when /water|oxygen|methane|hydrogen|helium/i
      # Volatiles can be extracted locally on lunar/planetary surfaces
      has_volatiles_extractor = settlement.inventory.items.any? { |item| item.name.downcase.include?('volatiles extractor') }
      if has_volatiles_extractor && is_lunar_settlement
        ['isru', settlement.location&.name || 'luna']
      else
        ['ai_autofulfill', 'earth']
      end
    
    when /steel|aluminum|titanium|iron/i
      # Metals require industrial ISRU (smelters, furnaces) - lunar precursor lacks these
      has_industrial_isru = settlement.inventory.items.any? { |item| 
        item.name.downcase.include?('smelter') || 
        item.name.downcase.include?('furnace') || 
        item.name.downcase.include?('metal printer')
      }
      if has_industrial_isru && is_lunar_settlement
        ['isru', settlement.location&.name || 'luna']
      else
        ['ai_autofulfill', 'earth']
      end
    
    when /glass|silicate/i
      # Glass requires high-temperature processing - lunar precursor lacks this
      has_glass_production = settlement.inventory.items.any? { |item| 
        item.name.downcase.include?('glass furnace') || 
        item.name.downcase.include?('silicate processor')
      }
      if has_glass_production && is_lunar_settlement
        ['isru', settlement.location&.name || 'luna']
      else
        ['ai_autofulfill', 'earth']
      end
    
    when /3d_printed|printed/i
      # 3D printed items are manufactured locally
      ['isru', settlement.location&.name || 'luna']
    
    else
      # Default to imported for unknown materials
      ['ai_autofulfill', 'earth']
    end
  end

  def self.categorize_material(material_name)
    case material_name.downcase
    when /regolith|ore|soil/
      'raw_materials'
    when /steel|aluminum|titanium|glass|composite/
      'processed_materials'
    when /oxygen|water|methane|hydrogen/
      'life_support'
    when /food|biomass/
      'organic'
    when /electronic|circuit|battery|fuel_cell/
      'technology'
    else
      'other'
    end
  end

  def self.calculate_inventory_value(inventory_data)
    # Realistic lunar base economics
    inventory_data.sum do |item|
      material = item[:material].downcase
      procurement = item[:procurement_method]
      source = item[:source_body]

      # Local lunar harvesting is FREE
      if procurement == 'isru' || source == 'luna' || source.include?('lunar') || source.include?('lava')
        0.0
      elsif procurement == 'manufactured'
        # Manufactured items may contain imported components
        # Estimate based on typical construction material costs
        case material
        when /rover|robot|vehicle/i
          # Assume 30% imported metals, 70% local materials
          0.3 * 5000.0 * item[:quantity]  # ~$5,000/kg for imported components
        when /printer|extractor|unit/i
          # Assume 20% imported materials
          0.2 * 3000.0 * item[:quantity]
        else
          # Assume 10% imported materials for other equipment
          0.1 * 2000.0 * item[:quantity]
        end
      else
        # Earth imports: market price + launch costs ($10,000/kg launch cost estimate)
        launch_cost_per_kg = 10000.0 # $10,000/kg to LEO, higher for lunar surface

        case material
        when /steel/
          earth_price_per_kg = 0.5  # ~$0.50/kg for steel
          (earth_price_per_kg + launch_cost_per_kg) * item[:quantity]
        when /glass|silicate/
          earth_price_per_kg = 1.0  # ~$1.00/kg for glass
          (earth_price_per_kg + launch_cost_per_kg) * item[:quantity]
        when /regolith/ # Imported regolith (not lunar)
          earth_price_per_kg = 0.1  # Minimal Earth processing
          (earth_price_per_kg + launch_cost_per_kg) * item[:quantity]
        when /oxygen|water/
          earth_price_per_kg = 50.0  # Very expensive to produce on Earth
          (earth_price_per_kg + launch_cost_per_kg) * item[:quantity]
        when /aluminum|titanium/
          earth_price_per_kg = 2.0  # ~$2.00/kg for aerospace metals
          (earth_price_per_kg + launch_cost_per_kg) * item[:quantity]
        else
          # Default: assume processed material
          earth_price_per_kg = 5.0  # Conservative estimate
          (earth_price_per_kg + launch_cost_per_kg) * item[:quantity]
        end
      end
    end
  end

  def self.summarize_procurement(procurement_data)
    summary = {
      total_procurement: procurement_data.length,
      by_method: {},
      by_material: {},
      total_quantity: 0
    }

    procurement_data.each do |entry|
      method = entry['procurement_method']
      material = entry['material']
      quantity = entry['quantity'].to_i

      summary[:by_method][method] ||= 0
      summary[:by_method][method] += quantity

      summary[:by_material][material] ||= 0
      summary[:by_material][material] += quantity

      summary[:total_quantity] += quantity
    end

    summary
  end

  def self.summarize_revenue(revenue_data)
    summary = {
      total_transactions: revenue_data.length,
      total_revenue_usd: 0.0,
      by_material: {},
      by_buyer: {},
      average_transaction_value: 0.0
    }

    revenue_data.each do |entry|
      material = entry['material']
      buyer = entry['buyer']
      revenue = entry['revenue_usd'].to_f

      summary[:total_revenue_usd] += revenue

      summary[:by_material][material] ||= 0.0
      summary[:by_material][material] += revenue

      summary[:by_buyer][buyer] ||= 0.0
      summary[:by_buyer][buyer] += revenue
    end

    if summary[:total_transactions] > 0
      summary[:average_transaction_value] = summary[:total_revenue_usd] / summary[:total_transactions]
    end

    summary
  end

  def self.analyze_inventory_trends(snapshots)
    return {} if snapshots.length < 2

    latest = snapshots.last
    previous = snapshots[-2]

    trends = {}
    latest['inventory'].each do |item|
      material = item['material']
      current_qty = item['quantity']
      prev_item = previous['inventory'].find { |i| i['material'] == material }
      prev_qty = prev_item ? prev_item['quantity'] : 0

      trends[material] = {
        current: current_qty,
        previous: prev_qty,
        change: current_qty - prev_qty,
        trend: current_qty > prev_qty ? 'increasing' : current_qty < prev_qty ? 'decreasing' : 'stable'
      }
    end

    trends
  end

  def self.calculate_efficiency_metrics(procurement_data, latest_snapshot, revenue_data = [])
    return {} unless latest_snapshot

    procured_by_method = procurement_data.group_by { |p| p['procurement_method'] }

    metrics = {}
    procured_by_method.each do |method, entries|
      total_quantity = entries.sum { |e| e['quantity'].to_f }
      unique_materials = entries.map { |e| e['material'] }.uniq.length

      metrics[method] = {
        total_quantity: total_quantity,
        unique_materials: unique_materials,
        average_order_size: total_quantity.to_f / entries.length,
        procurement_frequency: entries.length.to_f / 24.hours # per hour
      }
    end

    # Calculate ISRU efficiency (materials produced vs consumed)
    isru_entries = procurement_data.select { |p| p['procurement_method'] == 'isru' }
    import_entries = procurement_data.select { |p| p['procurement_method'] == 'ai_autofulfill' }

    if isru_entries.any? || import_entries.any?
      isru_total = isru_entries.sum { |e| e['quantity'].to_f }
      import_total = import_entries.sum { |e| e['quantity'].to_f }

      metrics['overall_efficiency'] = {
        isru_ratio: isru_total.to_f / (isru_total + import_total),
        import_ratio: import_total.to_f / (isru_total + import_total),
        self_sufficiency: isru_total > 0 ? (isru_total.to_f / (isru_total + import_total)) * 100 : 0
      }
    end

    # Calculate revenue efficiency
    if revenue_data.any?
      total_revenue = revenue_data.sum { |r| r['revenue_usd'].to_f }
      total_export_quantity = revenue_data.sum { |r| r['quantity'].to_f }
      
      # Calculate profit margin (revenue vs procurement costs)
      procurement_costs = procurement_data.sum do |p|
        quantity = p['quantity'].to_f
        if p['procurement_method'] == 'ai_autofulfill'
          # Estimate import costs
          material = p['material'].downcase
          if material.include?('steel')
            quantity * (0.5 + 10000) # market + launch
          elsif material.include?('glass')
            quantity * (1.0 + 10000)
          else
            quantity * (5.0 + 10000) # default
          end
        else
          0.0 # ISRU is free
        end
      end

      metrics['revenue_efficiency'] = {
        total_revenue_usd: total_revenue,
        total_export_quantity: total_export_quantity,
        average_revenue_per_unit: total_export_quantity > 0 ? total_revenue / total_export_quantity : 0,
        profit_margin: procurement_costs > 0 ? ((total_revenue - procurement_costs) / procurement_costs) * 100 : 0,
        net_profit_usd: total_revenue - procurement_costs
      }
    end

    metrics
  end
end