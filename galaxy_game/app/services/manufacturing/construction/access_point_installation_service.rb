# app/services/manufacturing/construction/access_point_installation_service.rb
module Manufacturing
  module Construction
    class AccessPointInstallationService
      def initialize(access_point, unit_type)
        @access_point = access_point
        @unit_type = unit_type
        @lava_tube = access_point.lava_tube
        @settlement = @lava_tube&.settlement

        # Get the blueprint for this unit type
        @blueprint = LookupService.find_blueprint('unit', @unit_type)
      end

      def schedule_installation
        # 1. Calculate required materials
        materials_needed = calculate_materials

        # 2. Create a construction job
        construction_job = ConstructionJob.create!(
          jobable: @access_point,
          job_type: 'access_point_modification',
          status: 'materials_pending',
          blueprint_id: @blueprint&.id,
          target_values: { unit_type: @unit_type }
        )

        # 3. Create material requests
        material_requests = Manufacturing::MaterialRequest.create_material_requests(
          construction_job,
          materials_needed
        )

        # 4. Create equipment requests
        equipment_requests = create_equipment_requests(construction_job)

        # 5. Update access point status
        @access_point.update(
          conversion_status: "installation_pending",
          notes: "Installation scheduled for #{@unit_type}"
        )

        # Return the job for tracking
        construction_job
      end

      def calculate_materials
        # Get the base materials from the blueprint
        base_materials = @blueprint&.materials || {}

        # Calculate additional materials based on access point size
        case @access_point.access_type
        when 'small'
          base_materials['steel'] = (base_materials['steel'] || 0) + 100
          base_materials['glass'] = (base_materials['glass'] || 0) + 20
        when 'medium'
          base_materials['steel'] = (base_materials['steel'] || 0) + 300
          base_materials['glass'] = (base_materials['glass'] || 0) + 50
        when 'large'
          base_materials['steel'] = (base_materials['steel'] || 0) + 750
          base_materials['glass'] = (base_materials['glass'] || 0) + 120
        end

        # Add sealant materials (always needed)
        base_materials['sealant'] = (base_materials['sealant'] || 0) + 50

        base_materials
      end

      def create_equipment_requests(construction_job)
        # Equipment depends on unit type
        equipment = []

        if @unit_type.include?('airlock')
          equipment << { type: 'crane', quantity: 1 }
          equipment << { type: 'welding_rig', quantity: 2 }
        elsif @unit_type.include?('hatch')
          equipment << { type: 'welding_rig', quantity: 1 }
        end

        equipment.each do |eq|
          construction_job.equipment_requests.create!(
            equipment_type: eq[:type],
            quantity_requested: eq[:quantity],
            status: 'pending'
          )
        end
      end

      # Methods for starting and completing installation would also be included
    end
  end
end