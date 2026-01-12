module Construction
  class OrbitalShipyardService
    # Manages construction projects for massive orbital crafts at stations

    def self.create_shipyard_project(station, craft_blueprint_id, options = {})
      # Create a construction project record for the station
      project = OrbitalConstructionProject.create!(
        station: station,
        craft_blueprint_id: craft_blueprint_id,
        status: 'materials_pending',
        progress_percentage: 0.0,
        required_materials: calculate_required_materials(craft_blueprint_id),
        delivered_materials: {},
        estimated_completion_time: options[:estimated_completion_time],
        project_metadata: options[:metadata] || {}
      )

      # Initialize material tracking
      initialize_material_tracking(project)

      project
    end

    def self.deliver_materials(station, material_type, quantity, source_settlement = nil)
      # Find active shipyard projects at this station
      active_projects = station.orbital_construction_projects.where(status: ['materials_pending', 'in_progress'])

      active_projects.each do |project|
        consumed = consume_materials_for_project(project, material_type, quantity)
        quantity -= consumed

        # Check if project is ready to start construction
        check_project_readiness(project)

        break if quantity <= 0
      end

      # Return unconsumed quantity
      quantity
    end

    def self.update_construction_progress
      # Process all active construction projects
      OrbitalConstructionProject.where(status: 'in_progress').each do |project|
        advance_construction(project)
      end
    end

    def self.complete_project(project)
      # Mark project as completed and spawn the craft
      project.update!(status: 'completed', progress_percentage: 100.0, completed_at: Time.current)

      # Create the completed craft at the station
      spawn_completed_craft(project)
    end

    private

    def self.calculate_required_materials(blueprint_id)
      # Load blueprint and calculate total materials needed
      blueprint = load_craft_blueprint(blueprint_id)

      required = {}
      blueprint['blueprint_data']['materials'].each do |material|
        required[material['id']] = material['amount']
      end

      required
    end

    def self.initialize_material_tracking(project)
      # Initialize delivered_materials hash with zero values
      delivered = {}
      project.required_materials.each_key do |material_id|
        delivered[material_id] = 0
      end
      project.update!(delivered_materials: delivered)
    end

    def self.consume_materials_for_project(project, material_type, quantity)
      return 0 unless project.required_materials[material_type]

      needed = project.required_materials[material_type] - project.delivered_materials[material_type]
      return 0 if needed <= 0

      consumed = [quantity, needed].min

      # Update delivered materials
      updated_delivered = project.delivered_materials.dup
      updated_delivered[material_type] += consumed
      project.update!(delivered_materials: updated_delivered)

      consumed
    end

    def self.check_project_readiness(project)
      # Check if all required materials are delivered
      all_materials_ready = project.required_materials.all? do |material_id, required_qty|
        project.delivered_materials[material_id] >= required_qty
      end

      if all_materials_ready && project.status == 'materials_pending'
        project.update!(status: 'in_progress', construction_started_at: Time.current)
      end
    end

    def self.advance_construction(project)
      # Simple progress advancement - in reality this would be more complex
      # based on workforce, tools, etc.
      progress_increment = 1.0 # 1% per update cycle

      new_progress = [project.progress_percentage + progress_increment, 100.0].min
      project.update!(progress_percentage: new_progress)

      # Check for completion
      if new_progress >= 100.0
        complete_project(project)
      end
    end

    def self.spawn_completed_craft(project)
      # Create the completed craft at the station
      blueprint = load_craft_blueprint(project.craft_blueprint_id)

      craft = Craft::BaseCraft.create!(
        name: "#{blueprint['name']} #{Time.current.to_i}",
        craft_name: blueprint['id'],
        craft_type: blueprint['category'],
        owner: project.station.owner, # Station owner
        operational_data: blueprint['operational_data'] || {},
        docked_at: project.station,
        status: :docked
      )

      # Log completion
      Rails.logger.info("Orbital construction completed: #{craft.name} at #{project.station.name}")

      craft
    end

    def self.load_craft_blueprint(blueprint_id)
      # Load blueprint from JSON data
      blueprint_path = GalaxyGame::Paths::CRAFT_BLUEPRINTS_PATH.join('space', 'spacecraft', "#{blueprint_id}_bp.json")

      if File.exist?(blueprint_path)
        JSON.parse(File.read(blueprint_path))
      else
        # Fallback to old data structure
        old_path = GalaxyGame::Paths::JSON_DATA.join('old-json-data', 'production_old3', 'crafts', 'transport', 'cyclers', "#{blueprint_id}_data.json")
        if File.exist?(old_path)
          JSON.parse(File.read(old_path))
        else
          raise "Blueprint not found: #{blueprint_id}"
        end
      end
    end
  end
end