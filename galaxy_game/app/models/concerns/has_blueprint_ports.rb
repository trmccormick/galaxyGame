# app/models/concerns/has_blueprint_ports.rb
module HasBlueprintPorts
  extend ActiveSupport::Concern

  def get_ports_data
    # Try operational_data first
    if operational_data&.dig('ports')
      return operational_data['ports']
    end
    
    # Look up blueprint data using the craft's own blueprint_id and category
    blueprint_service = Lookup::BlueprintLookupService.new
    blueprint_id = default_blueprint_id
    blueprint_data = blueprint_service.find_blueprint(blueprint_id, blueprint_category)
    
    if blueprint_data&.dig('ports')
      return blueprint_data['ports']
    end
    
    # Log error and return nil instead of silently granting ports
    Rails.logger.error(
      "No ports data found for #{self.class.name} " \
      "(blueprint_id: #{blueprint_id}, category: #{blueprint_category})"
    )
    nil
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