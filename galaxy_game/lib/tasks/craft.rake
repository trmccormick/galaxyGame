namespace :craft do
  desc "Reset and reload operational data for all crafts"
  task reset_all: :environment do
    Craft::BaseCraft.all.each do |craft|
      if craft.respond_to?(:reload_operational_data)
        craft.reload_operational_data
        puts "🔄 Reloaded operational data for #{craft.craft_name} (ID: #{craft.id})"
      else
        puts "⚠️ #{craft.craft_name} (ID: #{craft.id}) does not support operational data reload."
      end
    end
  end  

  desc "Check all satellites for mining setup"
  task check_mining: :environment do
    Craft::Satellite::BaseSatellite.all.each do |sat|
      if sat.respond_to?(:mine_gcc)
        if sat.can_mine_gcc?
          puts "✅ #{sat.craft_name} (ID: #{sat.id}) is ready for mining."
        else
          puts "⚠️ #{sat.craft_name} (ID: #{sat.id}) cannot mine GCC (missing requirements)."
        end
      else
        puts "❌ #{sat.craft_name} (ID: #{sat.id}) does not support mining."
      end
    end
  end  

  desc "Reload operational data for mining satellites that cannot mine"
  task reload_mining_sats: :environment do
    Craft::Satellite::BaseSatellite.all.each do |sat|
      if sat.respond_to?(:mine_gcc) && !sat.can_mine_gcc?
        if sat.respond_to?(:reload_operational_data)
          if sat.reload_operational_data
            puts "🔄 Reloaded operational data for #{sat.craft_name} (ID: #{sat.id})"
          else
            puts "❌ Failed to reload operational data for #{sat.craft_name} (ID: #{sat.id})"
          end
        else
          puts "⚠️ #{sat.craft_name} (ID: #{sat.id}) does not support operational data reload."
        end
      end
    end
  end

  desc "Build missing units, modules, and rigs for mining satellites that cannot mine"
  task fix_mining_sats: :environment do
    Craft::Satellite::BaseSatellite.all.each do |sat|
      if sat.respond_to?(:mine_gcc) && !sat.can_mine_gcc?
        sat.build_units_and_modules
        puts "🛠️ Built units/modules/rigs for #{sat.craft_name} (ID: #{sat.id})"
      end
    end
  end  

  desc "Factory refit for mining satellites that cannot mine"
  task factory_refit_mining_sats: :environment do
    Craft::Satellite::BaseSatellite.all.each do |sat|
      if sat.respond_to?(:mine_gcc) && !sat.can_mine_gcc?
        sat.factory_refit!
        puts "🛠️ Factory refit completed for #{sat.craft_name} (ID: #{sat.id})"
      end
    end
  end

  desc "Compare each craft's setup to the latest recommended fit from operational data"
  task compare_fit_to_latest: :environment do
    Craft::BaseCraft.all.each do |craft|
      # Get latest operational data from lookup service
      lookup_service = Lookup::CraftLookupService.new
      latest_data = lookup_service.find_craft(craft.craft_type)
      unless latest_data
        puts "⚠️ Could not find operational data for #{craft.craft_name} (ID: #{craft.id})"
        next
      end

      latest_fit = latest_data['recommended_fit'] || {}
      latest_units = (latest_fit['units'] || []).map { |u| [u['id'], u['count']] }.to_h
      latest_modules = (latest_fit['modules'] || []).map { |m| [m['id'], m['count']] }.to_h
      latest_rigs = (latest_fit['rigs'] || []).map { |r| [r['id'], r['count']] }.to_h

      # Get actual setup
      actual_units = craft.base_units.group_by(&:unit_type).transform_values(&:count)
      actual_modules = craft.base_modules.group_by(&:module_type).transform_values(&:count)
      actual_rigs = craft.base_rigs.group_by(&:rig_type).transform_values(&:count)

      # Compare units
      unit_mismatches = latest_units.select { |id, count| actual_units[id] != count }
      module_mismatches = latest_modules.select { |id, count| actual_modules[id] != count }
      rig_mismatches = latest_rigs.select { |id, count| actual_rigs[id] != count }

      if unit_mismatches.empty? && module_mismatches.empty? && rig_mismatches.empty?
        puts "✅ #{craft.craft_name} (ID: #{craft.id}) matches the latest recommended fit."
      else
        puts "❌ #{craft.craft_name} (ID: #{craft.id}) is OUT OF SYNC with latest recommended fit:"
        unit_mismatches.each do |id, count|
          puts "   - Unit '#{id}': expected #{count}, found #{actual_units[id] || 0}"
        end
        module_mismatches.each do |id, count|
          puts "   - Module '#{id}': expected #{count}, found #{actual_modules[id] || 0}"
        end
        rig_mismatches.each do |id, count|
          puts "   - Rig '#{id}': expected #{count}, found #{actual_rigs[id] || 0}"
        end
      end
    end
  end
end
