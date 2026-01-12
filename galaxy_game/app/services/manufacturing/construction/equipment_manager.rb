module Manufacturing
  module Construction
  class EquipmentManager
    def self.release_equipment(construction_job)
      # Release all equipment back to inventory
      construction_job.equipment_requests.each do |request|
        next unless request.status == 'fulfilled'
        
        # Mark equipment as released
        request.update(status: 'released')
      end
    end
  end
end
end