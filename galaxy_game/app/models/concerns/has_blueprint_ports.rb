# app/models/concerns/has_blueprint_ports.rb
module HasBlueprintPorts
  extend ActiveSupport::Concern

  def get_ports_data
    # Try operational_data first
    if operational_data&.dig('ports')
      return operational_data['ports']
    end
    
    # Fallback to blueprint data
    blueprint_service = Lookup::BlueprintLookupService.new
    
    # Try the specific blueprint ID first
    blueprint_id = 'generic_satellite'
    blueprint_data = blueprint_service.find_blueprint(blueprint_id, 'satellite')
    
    if blueprint_data&.dig('ports')
      return blueprint_data['ports']
    end
    
    # If that fails, try the default_blueprint_id from the class
    blueprint_id = default_blueprint_id
    blueprint_data = blueprint_service.find_blueprint(blueprint_id, blueprint_category)
    
    if blueprint_data&.dig('ports')
      return blueprint_data['ports']
    end
    
    # Return default ports if no blueprint data found
    {
      'internal_module_ports' => 5,
      'external_module_ports' => 5,
      'internal_rig_ports' => 5,
      'external_rig_ports' => 5
    }
  end

  private

  # These methods should be implemented by the including class
  def default_blueprint_id
    raise NotImplementedError, "#{self.class} must implement #default_blueprint_id"
  end

  def blueprint_category
    raise NotImplementedError, "#{self.class} must implement #blueprint_category"
  end
end