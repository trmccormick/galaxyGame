class Manufacturing::MaterialRequestSystem
    def self.check_and_request(construction_project)
      missing_materials = find_missing_materials(construction_project)
  
      if missing_materials.any?
        missing_materials.each do |material, quantity|
          create_request(construction_project, material, quantity)
        end
        return false # Materials are still being gathered
      end
  
      true # All materials are available
    end
  
    def self.find_missing_materials(construction_project)
      required_materials = construction_project.required_materials
      missing = {}
  
      required_materials.each do |material, quantity|
        available = Inventory.check(material)
        if available < quantity
          missing[material] = quantity - available
        end
      end
  
      missing
    end
  
    def self.create_request(construction_project, material, quantity)
      MaterialRequest.create!(
        construction_project: construction_project,
        material: material,
        quantity: quantity,
        status: :pending
      )
  
      trigger_resource_gathering(material, quantity)
    end
  
    def self.trigger_resource_gathering(material, quantity)
      # Determine if we mine, refine, or import the material
      if MiningOperation.can_extract?(material)
        MiningOperation.start_extraction(material, quantity)
      elsif Refinery.can_process?(material)
        Refinery.start_processing(material, quantity)
      else
        ImportSystem.order_import(material, quantity)
      end
    end
  
    def self.fulfill_request(material_request)
      material_request.update(status: :fulfilled)
      check_construction_ready(material_request.construction_project)
    end
  
    def self.check_construction_ready(construction_project)
      if MaterialRequest.where(construction_project: construction_project, status: :pending).none?
        ConstructionManager.resume_project(construction_project)
      end
    end
  end
  