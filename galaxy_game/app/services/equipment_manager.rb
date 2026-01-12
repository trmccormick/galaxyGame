class EquipmentManager
  # Check if equipment is available
  def self.equipment_available?(equipment_type, quantity, settlement)
    equipment = settlement.equipment.where(
      type: equipment_type, 
      status: 'available'
    )
    
    equipment.count >= quantity
  end
  
  # Reserve equipment for a job
  def self.reserve_equipment(equipment_request)
    return false unless equipment_request.requestable.respond_to?(:settlement)
    
    settlement = equipment_request.requestable.settlement
    return false unless settlement
    
    equipment_type = equipment_request.equipment_type
    quantity_needed = equipment_request.quantity_still_needed
    
    # Find available equipment
    available_equipment = settlement.equipment.where(
      type: equipment_type, 
      status: 'available'
    ).limit(quantity_needed)
    
    if available_equipment.count < quantity_needed
      # Not enough equipment
      return false
    end
    
    # Reserve the equipment
    available_equipment.update_all(
      status: 'reserved',
      reserved_for_id: equipment_request.requestable_id,
      reserved_for_type: equipment_request.requestable_type
    )
    
    # Update the request
    equipment_request.update(
      status: 'fulfilled',
      quantity_fulfilled: available_equipment.count,
      fulfilled_at: Time.current
    )
    
    true
  end
  
  # Release equipment when job is done
  def self.release_equipment(construction_job)
    # Find all equipment reserved for this job
    reserved_equipment = Equipment.where(
      reserved_for_id: construction_job.id,
      reserved_for_type: construction_job.class.name
    )
    
    # Release the equipment
    reserved_equipment.update_all(
      status: 'available',
      reserved_for_id: nil,
      reserved_for_type: nil
    )
    
    true
  end
end