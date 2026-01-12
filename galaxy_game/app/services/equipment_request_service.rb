class EquipmentRequestService
  def self.create_equipment_requests(requestable, equipment_array)
    equipment_requests = []

    equipment_array.each do |equipment_item|
      equipment_requests << requestable.equipment_requests.create!(
        equipment_type: equipment_item[:name] || equipment_item['name'] || equipment_item[:type] || equipment_item['type'] || equipment_item[:equipment_type] || equipment_item['equipment_type'],
        quantity_requested: equipment_item[:quantity] || equipment_item['quantity'] || 1,
        status: 'pending',
        priority: determine_priority(equipment_item[:name] || equipment_item['name'] || equipment_item[:type] || equipment_item['type'] || equipment_item[:equipment_type] || equipment_item['equipment_type'])
      )
    end

    equipment_requests
  end

  def self.create_equipment_requests_from_hash(requestable, equipment_hash)
    equipment_requests = []

    equipment_hash.each do |equipment_type, quantity|
      equipment_requests << requestable.equipment_requests.create!(
        equipment_type: equipment_type,
        quantity_requested: quantity,
        status: 'pending',
        priority: determine_priority(equipment_type)
      )
    end

    equipment_requests
  end

  # Helper to determine priority based on equipment type
  def self.determine_priority(equipment_type)
    # Critical equipment gets high priority
    if ['life_support_system', 'emergency_oxygen'].include?(equipment_type)
      'critical'
    # Construction equipment gets high priority
    elsif ['space_construction_drone', 'heavy_duty_fastening_system'].include?(equipment_type)
      'high'
    # Basic tools get normal priority
    else
      'normal'
    end
  end

  def self.fulfill_request(equipment_request)
    # Check if equipment pool has enough of the requested equipment
    available = EquipmentPool.check_availability(equipment_request.equipment_type)

    if available >= equipment_request.quantity_requested
      # Reserve the equipment from pool
      EquipmentPool.reserve(equipment_request.equipment_type, equipment_request.quantity_requested)

      # Mark request as fulfilled
      equipment_request.update(
        status: 'fulfilled',
        fulfilled_at: Time.current,
        quantity_fulfilled: equipment_request.quantity_requested
      )

      # Check if all equipment requests for the job are fulfilled
      requestable = equipment_request.requestable
      if requestable.respond_to?(:equipment_requests)
        all_fulfilled = requestable.equipment_requests.all? { |req| req.status == 'fulfilled' }

        # If all are fulfilled, we can proceed with construction
        # (This would typically trigger the next step in the workflow)
      end

      return true
    end

    # Not enough equipment available
    equipment_request.update(
      status: 'partially_fulfilled',
      quantity_fulfilled: available
    )

    false
  end
end