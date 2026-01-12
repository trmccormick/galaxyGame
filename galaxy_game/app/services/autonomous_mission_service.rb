class AutonomousMissionService
  def self.launch_mission(mission_id)
    # Create mission record
    mission = Mission.create!(
      identifier: mission_id,
      mission_type: 'autonomous',
      status: 'launching'
    )
    
    # Load mission manifest
    manifest = load_mission_manifest(mission_id)
    
    # Create starship
    starship = create_starship(manifest['starship'])
    
    # Create launch financing bond if this is a financed mission
    create_launch_financing_bond(manifest, starship)
    
    # Create inventory
    inventory = create_inventory(manifest['inventory'], starship)
    
    # Select landing site
    location = select_landing_site(manifest)
    
    # Create initial settlement if this is a base-building mission
    settlement = create_initial_settlement(manifest, location) if base_building_mission?(manifest)
    
    # Update mission record
    mission.update(
      status: 'in_progress',
      location: location,
      starship: starship
    )
    
    # Execute the automated setup sequence
    if base_building_mission?(manifest) && settlement
      execute_base_building_sequence(manifest, settlement, starship)
    end
    
    mission
  end
  
  private
  
  def self.load_mission_manifest(mission_id)
    # First try direct path
    file_path = Rails.root.join('..', 'data', 'json-data', 'manifests', 'missions', "#{mission_id}.json")
    
    # If not found, search recursively for manifest files with matching ID
    unless File.exist?(file_path)
      manifests_dir = Rails.root.join('..', 'data', 'json-data', 'manifests', 'missions')
      Dir.glob("#{manifests_dir}/**/*.json").each do |file|
        begin
          data = JSON.parse(File.read(file))
          if data['manifest_id'] == mission_id || data['manifest_id']&.include?(mission_id)
            file_path = file
            break
          end
        rescue JSON::ParserError
          next
        end
      end
    end
    
    JSON.parse(File.read(file_path))
  end
  
  def self.create_starship(starship_config)
    # Create the starship record
    starship = Craft::Starship.create!(
      name: starship_config['craft_name'],
      craft_type: starship_config['craft_type'],
      craft_sub_type: starship_config['craft_sub_type'],
      status: 'in_transit'
    )
    
    # Add custom configuration
    if starship_config['custom_configuration'] && starship_config['custom_configuration']['installed_units']
      starship_config['custom_configuration']['installed_units'].each do |unit_config|
        unit = Unit.create!(
          name: unit_config['name'],
          unit_type: unit_config['unit_type'],
          operational_data: unit_config['operational_data'] || {},
          status: 'installed',
          installable: starship
        )
        
        # Create connection if specified
        if unit_config['connection']
          port = starship.ports.find_by(
            port_type: unit_config['connection']['port_type'],
            name: unit_config['connection']['port_name']
          )
          
          if port
            Connection.create!(
              port: port,
              unit: unit,
              status: 'connected'
            )
          end
        end
      end
    end
    
    starship
  end
  
  def self.create_launch_financing_bond(manifest, starship)
    # Create launch financing bond for financed missions
    financing = manifest['financing']
    return unless financing && financing['required']
    
    # Find the organizations
    astrolift = Organizations::Corporation.find_by(identifier: 'ASTROLIFT')
    ldc = Organizations::DevelopmentCorporation.find_by(identifier: 'LDC')
    usd_currency = Financial::Currency.find_by(symbol: 'USD')
    
    return unless astrolift && ldc && usd_currency
    
    # Find or create accounts
    astrolift_usd_account = Financial::Account.find_or_create_for_entity_and_currency(
      accountable_entity: astrolift, currency: usd_currency
    )
    ldc_usd_account = Financial::Account.find_or_create_for_entity_and_currency(
      accountable_entity: ldc, currency: usd_currency
    )
    
    bond_amount = financing['amount'] || 1857986.22
    maturity_days = financing['maturity_days'] || 180
    
    bond = Financial::Bond.find_or_create_by!(
      issuer: astrolift,
      holder: ldc,
      currency: usd_currency,
      amount: bond_amount,
      issued_at: Time.current,
      due_at: Time.current + maturity_days.days
    ) do |b|
      b.interest_rate = financing['interest_rate'] || 0.05
      b.description = financing['description'] || "Launch debt financing for #{manifest['manifest_id']}"
    end
    
    # Credit the bond amount to AstroLift's USD account
    astrolift_usd_account.deposit(bond_amount, "Bond issuance for #{manifest['manifest_id']} financing")
    
    Rails.logger.info "Created launch financing bond: #{bond.description} (Amount: $#{bond_amount}, ID: #{bond.id})"
  end
  
  def self.create_inventory(inventory_config, owner)
    # Create inventory
    inventory = Inventory.create!(inventoryable: owner)
    
    # Add units to inventory
    if inventory_config['units']
      inventory_config['units'].each do |unit_config|
        # Create as inventory items rather than deployed units
        item = inventory.items.create!(
          name: unit_config['name'],
          quantity: unit_config['count'] || 1,
          item_type: 'unit',
          properties: unit_config.except('name', 'count')
        )
      end
    end
    
    # Add supplies and consumables
    ['supplies', 'consumables'].each do |category|
      if inventory_config[category]
        inventory_config[category].each do |item_config|
          inventory.items.create!(
            name: item_config['name'],
            quantity: item_config['count'] || 1,
            item_type: category.singularize,
            properties: item_config.except('name', 'count')
          )
        end
      end
    end
    
    inventory
  end
  
  def self.select_landing_site(manifest)
    # In a real implementation, this might involve geographical calculations
    # For now, we'll use a predefined location
    
    # Check if this is the lunar mission
    if manifest['mission_id'].include?('lunar') || manifest['description'].downcase.include?('lunar')
      location = Location.find_or_create_by!(
        name: "Marius Hills Lava Tube",
        coordinates: "14.1°N 56.8°W",
        celestial_body: CelestialBody.find_by(name: 'Luna')
      )
    else
      # Default location
      location = Location.find_or_create_by!(
        name: "Default Landing Site",
        coordinates: "0.0°N 0.0°E",
        celestial_body: CelestialBody.first
      )
    end
    
    location
  end
  
  def self.base_building_mission?(manifest)
    manifest['mission_type'] == 'base_building' || 
    manifest['description'].downcase.include?('base') ||
    manifest['description'].downcase.include?('settlement')
  end
  
  def self.create_initial_settlement(manifest, location)
    # Find or create the appropriate development corporation based on celestial body
    corporation = find_or_create_development_corporation(location.celestial_body)
    
    # Create the settlement
    settlement = Settlement::BaseSettlement.create!(
      name: manifest['settlement_name'] || "#{corporation.identifier} Initial Outpost",
      location: location,
      owner: corporation,
      settlement_type: 'automated_outpost',
      current_population: 0,
      operational_data: { 
        automated: true,
        establishment_date: Time.current,
        founding_mission: manifest['mission_id']
      }
    )
    
    # Create settlement inventory
    unless settlement.inventory
      inventory = Inventory.create!(inventoryable: settlement)
    end
    
    # If this is the first lunar settlement, establish the Luna Gateway Consortium
    if location.celestial_body.name == 'Luna' && corporation.identifier == 'LDC'
      establish_luna_gateway_consortium(corporation)
    end
    
    settlement
  end
  
  def self.find_or_create_development_corporation(celestial_body)
    case celestial_body.name
    when 'Luna'
      identifier = 'LDC'
      name = 'Lunar Development Corporation'
    when 'Mars'
      identifier = 'MDC'
      name = 'Mars Development Corporation'
    when 'Venus'
      identifier = 'VDC'
      name = 'Venus Development Corporation'
    when 'Titan'
      identifier = 'TDC'
      name = 'Titan Development Corporation'
    else
      identifier = 'SCD'
      name = 'Sol Central Development'
    end
    
    Organizations::DevelopmentCorporation.find_or_create_by!(identifier: identifier) do |org|
      org.name = name
      org.organization_type = :development_corporation
    end
  end
  
  def self.establish_luna_gateway_consortium(ldc)
    # Find AstroLift corporation
    astrolift = Organizations::Corporation.find_by(identifier: 'ASTROLIFT')
    return unless astrolift
    
    # Create the joint venture
    consortium = Organizations::BaseOrganization.find_or_create_by!(identifier: 'LUNA-GATEWAY') do |org|
      org.name = 'Luna Gateway Consortium'
      org.organization_type = :joint_venture
      org.operational_data = {
        'parent_organizations' => [ldc.id, astrolift.id],
        'description' => 'Joint venture between LDC and AstroLift managing Earth-Luna orbital logistics and gateway operations'
      }
    end
    
    Rails.logger.info "Established Luna Gateway Consortium: #{consortium.name} (ID: #{consortium.id})"
    
    # Create accounts for the consortium
    gcc_currency = Financial::Currency.find_by(symbol: 'GCC')
    usd_currency = Financial::Currency.find_by(symbol: 'USD')
    
    if gcc_currency
      Financial::Account.find_or_create_for_entity_and_currency(
        accountable_entity: consortium, currency: gcc_currency
      )
    end
    
    if usd_currency
      Financial::Account.find_or_create_for_entity_and_currency(
        accountable_entity: consortium, currency: usd_currency
      )
    end
    
    Rails.logger.info "Created financial accounts for Luna Gateway Consortium"
  end
  
  def self.execute_base_building_sequence(manifest, settlement, starship)
    # 1. Find or create a suitable geological feature (lava tube preferred, valley or canyon as fallback)
    # Note: Lava tubes are most likely easier to seal than valleys or canyons due to their natural enclosure
    suitable_feature = find_or_create_worldhouse_feature(settlement.location)
    
    # 2. Create worldhouse on the suitable feature
    worldhouse = create_worldhouse_on_feature(suitable_feature, settlement)
    
    # 3. Transfer initial resources from starship to settlement
    transfer_initial_resources(starship, settlement)
    
    # 4. Queue worldhouse construction jobs
    queue_worldhouse_construction_jobs(worldhouse, settlement)
    
    # 5. Deploy initial robotic workforce
    deploy_robotic_workforce(settlement, manifest['robots'] || [])
    
    # Log mission progress
    Rails.logger.info("Base building sequence initiated for settlement: #{settlement.name}")
  end
  
  def self.find_or_create_worldhouse_feature(location)
    # Find or create a suitable geological feature for worldhouse construction
    # Priority order based on sealing difficulty: lava tubes are easiest to seal/pressurize
    # Priority: 1) Existing lava tube, 2) Existing natural valley, 3) Existing natural canyon, 4) New lava tube
    celestial_body = location.celestial_body
    
    # First check if a lava tube feature already exists for this celestial body
    # Lava tubes are preferred as they're naturally enclosed and easiest to seal/pressurize
    existing_feature = CelestialBodies::Features::LavaTube
      .where(celestial_body: celestial_body)
      .first
    
    return existing_feature if existing_feature
    
    # If no lava tube available, check for a suitable valley
    # Valleys require more extensive sealing work than lava tubes
    existing_valley = CelestialBodies::Features::Valley
      .where(celestial_body: celestial_body)
      .where(status: 'natural')
      .first
    
    return existing_valley if existing_valley
    
    # If no valley available, check for a suitable canyon
    # Canyons are the most challenging to seal due to their open, exposed nature
    existing_canyon = CelestialBodies::Features::Canyon
      .where(celestial_body: celestial_body)
      .where(status: 'natural')
      .first
    
    return existing_canyon if existing_canyon
    
    # If neither lava tube, valley, nor canyon available, create a new lava tube feature
    CelestialBodies::Features::LavaTube.create!(
      celestial_body: celestial_body,
      feature_id: "#{celestial_body.name.downcase}_lava_tube_#{Time.current.to_i}",
      status: 'natural',
      feature_type: 'lava_tube'
    )
  end
  
  def self.transfer_initial_resources(starship, settlement)
    # Get inventories
    starship_inventory = starship.inventory
    settlement_inventory = settlement.inventory
    
    return unless starship_inventory && settlement_inventory
    
    # Transfer basic construction materials and supplies
    ['processed_regolith', 'metal_extract', 'silicate_extract', 'structural_panels', 
     'transparent_panels', 'fasteners', 'sealant'].each do |material|
      
      item = starship_inventory.items.find_by(name: material)
      next unless item && item.quantity > 0
      
      # Create or update settlement inventory item
      settlement_item = settlement_inventory.items.find_or_create_by(name: material)
      settlement_item.update(quantity: settlement_item.quantity + item.quantity)
      
      # Remove from starship inventory
      item.update(quantity: 0)
    end
  end
  
  def self.deploy_robotic_workforce(settlement, robots_config)
    # Create robotic units in the settlement
    robots_config = default_robots if robots_config.empty?
    
    robots_config.each do |robot|
      # Add to settlement inventory
      item = settlement.inventory.items.find_or_create_by(
        name: robot['name'] || "Construction Robot",
        item_type: 'robot'
      )
      
      item.update(
        quantity: item.quantity + (robot['count'] || 1),
        properties: {
          type: robot['type'] || 'construction',
          capabilities: robot['capabilities'] || ['basic_construction', 'material_handling'],
          operational_status: 'ready'
        }
      )
    end
  end
  
  def self.create_worldhouse_on_feature(lava_tube_feature, settlement)
    # Create worldhouse on the lava tube feature
    Structures::Worldhouse.create!(
      geological_feature: lava_tube_feature,
      settlement: settlement,
      owner: settlement.owner,
      celestial_body: lava_tube_feature.celestial_body,
      name: "#{lava_tube_feature.name} Worldhouse",
      structure_type: 'worldhouse'
    )
  end
  
  def self.queue_worldhouse_construction_jobs(worldhouse, settlement)
    # Queue worldhouse segment construction jobs
    worldhouse.worldhouse_segments.each do |segment|
      # Create construction job for this segment
      construction_job = ConstructionJob.create!(
        jobable: segment,
        job_type: 'worldhouse_segment_construction',
        status: 'pending',
        priority: 'high',
        settlement: settlement
      )
      
      # Auto-fulfill material requests if this is initial setup
      if construction_job
        # Mark material requests as fulfilled since we transferred materials earlier
        construction_job.material_requests.update_all(status: 'fulfilled', fulfilled_at: Time.current)
        
        # Start construction automatically
        segment.begin_construction!
      end
    end
  end
  
  def self.default_robots
    [
      { name: "CAR-300 Construction Robot", type: "construction", count: 5, 
        capabilities: ['basic_construction', 'material_handling', 'excavation'] },
      { name: "SMR-500 Survey Robot", type: "survey", count: 2,
        capabilities: ['scanning', 'mapping', 'sample_collection'] },
      { name: "HRV-400 Resource Harvester", type: "harvester", count: 3,
        capabilities: ['mining', 'processing', 'transport'] }
    ]
  end
end