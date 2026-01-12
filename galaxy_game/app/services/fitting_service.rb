class FittingService
    def self.fit!(target:, fit_data:, inventory: nil, dry_run: false)
      result = FittingResult.new
      return result unless fit_data

      check_inventory = ->(name) {
        inventory.nil? || inventory.items.where(name: name).exists?
      }

      # Helper for dry_run mock
      mock_item = ->(id) { Struct.new(:id) { def persisted?; false; end }.new(id) }

      # Install units
      if fit_data['units']
        install_units(target, fit_data['units'], result, dry_run, check_inventory)
      end

      # Install modules
      if fit_data['modules']
        install_modules(target, fit_data['modules'], result, dry_run)
      end

      # Install rigs
      if fit_data['rigs']
        install_rigs(target, fit_data['rigs'], result, dry_run)
      end

      unless dry_run
        target.recalculate_effects if target.respond_to?(:recalculate_effects)
      end

      result
    end

    private

    def self.install_units(target, units, result, dry_run, check_inventory)
      unit_lookup = Lookup::UnitLookupService.new
      
      units.each do |unit_config|
        unit_id = unit_config['id']
        count = unit_config['count'] || 1
        
        # Check inventory first
        unless check_inventory.call(unit_id)
          result.missing << unit_id
          result.add_error("Missing inventory item: #{unit_id}")
          next
        end
        
        unit_data = unit_lookup.find_unit(unit_id)
        unless unit_data
          result.add_error("Unit definition not found: #{unit_id}")
          next
        end

        puts "  - Installing #{count}x #{unit_id}"
        
        count.times do |i|
          unless dry_run
            unit = create_unit(unit_id, unit_data, target, i + 1)
            if unit&.persisted? && target.install_unit(unit)
              result.fitted << unit
              puts "    ✅ Installed #{unit_id} (ID: #{unit.id})"
            else
              result.add_error("Failed to install #{unit_id}")
            end
          end
        end
      end
    end

    def self.install_modules(target, modules, result, dry_run)
      modules.each do |module_config|
        module_id = module_config['id']
        count = module_config['count'] || 1
        
        puts "  - Installing #{count}x #{module_id}"
        
        count.times do |i|
          unless dry_run
            # Use the concern method, not direct creation
            module_result = target.add_module(module_id)
            if module_result.is_a?(Modules::BaseModule)
              result.fitted << module_result
              puts "    ✅ Installed #{module_id} (ID: #{module_result.id})"
            else
              result.add_error("Failed to install #{module_id}: #{module_result}")
              puts "    ❌ Failed to install #{module_id}: #{module_result}"
            end
          end
        end
      end
    end

    def self.install_rigs(target, rigs, result, dry_run)
      rigs.each do |rig_config|
        rig_id = rig_config['id']
        count = rig_config['count'] || 1
        
        puts "  - Installing #{count}x #{rig_id}"
        
        count.times do |i|
          unless dry_run
            # Use the concern method, not direct creation
            rig_result = target.add_rig(rig_id)
            if rig_result.is_a?(Rigs::BaseRig)
              result.fitted << rig_result
              puts "    ✅ Installed #{rig_id} (ID: #{rig_result.id})"
            else
              result.add_error("Failed to install #{rig_id}: #{rig_result}")
              puts "    ❌ Failed to install #{rig_id}: #{rig_result}"
            end
          end
        end
      end
    end

    def self.create_unit(unit_id, unit_data, target, index)
      klass = case unit_id
              when /computer/
                Units::Computer
              when /battery/
                Units::Battery
              else
                Units::BaseUnit
              end

      klass.create(
        name: "#{unit_id}_#{index}",
        unit_type: unit_id,
        owner: target.owner,
        identifier: "#{unit_id.upcase}_#{target.name}_#{index}_#{SecureRandom.hex(4)}",
        operational_data: unit_data
      )
    end

    def self.create_module(module_id, module_data, target, index)
      Modules::BaseModule.create(
        name: "#{module_id}_#{index}",
        module_type: module_id,
        description: module_data['description'] || "No description provided",
        identifier: "#{module_id.upcase}_#{target.name}_#{index}_#{SecureRandom.hex(4)}",
        operational_data: module_data
      )
    end

    def self.create_rig(rig_id, rig_data, target, index)
      Rigs::BaseRig.create(
        name: "#{rig_id}_#{index}",
        rig_type: rig_id,
        description: rig_data['description'] || "No description provided",
        capacity: rig_data['capacity'] || 0,
        identifier: "#{rig_id.upcase}_#{target.name}_#{index}_#{SecureRandom.hex(4)}",
        operational_data: rig_data
      )
    end
end