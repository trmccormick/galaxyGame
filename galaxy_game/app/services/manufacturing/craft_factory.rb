class Manufacturing::CraftFactory
  def self.build_from_blueprint(blueprint_id:, variant_data:, owner:, location:)
    blueprint = Lookup::BlueprintLookupService.new.find_blueprint(blueprint_id)
    raise "Blueprint not found: #{blueprint_id}" unless blueprint

    # Load craft data using craft lookup service (like the working script)
    craft_lookup_service = Lookup::CraftLookupService.new
    craft_id = variant_data&.dig('craft', 'id') || variant_data&.dig('id') || "crypto_mining_satellite"
    satellite_data = craft_lookup_service.find_craft(craft_id)
    
    # Merge variant data if present
    craft_data = if variant_data
      satellite_data.deep_merge(variant_data)
    else
      satellite_data
    end

    # Determine craft class based on craft_type
    craft_class = determine_craft_class(craft_data['subcategory'] || craft_data['craft_type'])
    
    craft = craft_class.create!(
      name: "GCCSat-#{SecureRandom.hex(4)}", # Generate unique name like working script
      craft_name: craft_data['name'] || "Generic Satellite",
      craft_type: craft_data['subcategory'] || craft_data['craft_type'] || "space/satellites/mining",
      operational_data: craft_data, # Use full craft_data like working script
      owner: owner,
      current_location: location,
      deployed: false
    )

    puts "✅ Created #{craft_class.name}: #{craft.name} (ID: #{craft.id})"
    craft
  end

  private

  def self.determine_craft_class(craft_type)
    case craft_type&.downcase
    when /satellite.*mining/, /space.*satellites.*mining/
      Craft::Satellite::BaseSatellite
    when /satellite/
      Craft::Satellite::BaseSatellite
    when /starship/, /heavy.*lander/
      Craft::Transport::HeavyLander
    else
      Craft::BaseCraft
    end
  end
end