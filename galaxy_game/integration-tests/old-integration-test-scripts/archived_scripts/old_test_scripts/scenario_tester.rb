# app/sample_test_scripts/scenario_tester.rb

require 'json'

# Load the manifest file
manifest_path = Rails.root.join('app', 'data', 'starship-cargo-manifest', 'ssc-000-test.json')
begin
  manifest_content = File.read(manifest_path)
  @manifest = JSON.parse(manifest_content)
rescue JSON::ParserError => e
  puts "Error: Invalid JSON in manifest file"
  puts e.message
  exit 1
rescue Errno::ENOENT
  puts "Error: Manifest file not found at #{manifest_path}"
  exit 1
end

puts "\n--- AI Manager: #{@manifest['description']} ---"

# Initialize simulated environment
@simulation_time = 0
@current_power = 0
@battery_charge = 0
@battery_capacity = 0 # Assuming no initial battery
@power_grid_online = false
@simulated_units = {}
@unit_connections = {}
@remaining_inventory = Hash.new(0)

# Load initial inventory
if @manifest['inventory'] && @manifest['inventory']['units']
  @manifest['inventory']['units'].each do |unit_data|
    name = unit_data['name']
    count = unit_data['count'] || 1
    @remaining_inventory[name] += count
  end
end

puts "\nInitial Inventory (Power Test):"
@remaining_inventory.each { |name, count| puts "  #{name} (Count: #{count})" }
puts

# Find the Starship entity (assuming it exists in the database)
@starship = Craft::BaseCraft.find_by(craft_name: 'Starship (Lunar Variant)') # Or craft_name: 'Starship'
if @starship.nil?
  puts "Error: Starship (craft_name: Starship (Lunar Variant)) not found in the database!"
  exit 1
end
puts "Found Starship: #{@starship.name} (ID: #{@starship.id})"

def deploy_simulated_unit(unit_name)
  if @remaining_inventory[unit_name] > 0
    unit_id = "#{unit_name.downcase.gsub(' ', '_')}_#{@simulated_units.values.flatten.count}"
    @simulated_units[unit_name] ||= []
    @simulated_units[unit_name] << { id: unit_id, name: unit_name, power_on: false, state: 'idle' }
    @remaining_inventory[unit_name] -= 1
    puts "     Deployed simulated unit: #{unit_name} (ID: #{unit_id}). Remaining in inventory: #{@remaining_inventory[unit_name]}"
    true
  else
    puts "     Warning: Cannot deploy #{unit_name}. Not available in inventory."
    false
  end
end

def power_on_unit(unit_name)
  unit = @simulated_units[unit_name]&.first # Assuming we're powering on the first one found
  if unit
    unit[:power_on] = true
    puts "     Powered on simulated unit: #{unit_name} (ID: #{unit[:id]})"
    true
  else
    puts "     Warning: Cannot power on #{unit_name}. Not found among deployed units."
    false
  end
end

def set_unit_state(unit_name, state, target_resource = nil)
  unit = @simulated_units[unit_name]&.first
  if unit
    unit[:state] = state
    puts "     Set state of #{unit_name} (ID: #{unit[:id]}) to: #{state}#{target_resource ? ' (' + target_resource + ')' : ''}"
    true
  else
    puts "     Warning: Cannot set state of #{unit_name}. Not found among deployed units."
    false
  end
end

def get_port(unit, port_name)
  # In a real system, this would look up the port on the unit object
  { name: port_name } # Simple simulation
end

@manifest['task_list'].each do |task|
  puts "\nSimulation Time: Hour #{@simulation_time}"
  puts " Current Power: #{@current_power} watt, Battery Charge: #{@battery_charge}/#{@battery_capacity} watt-hour, Power Grid: #{@power_grid_online ? 'Online' : 'Offline'}"
  puts " Simulated Units: #{@simulated_units.transform_values(&:count)}"
  puts " Remaining Inventory: #{@remaining_inventory.select { |_, count| count > 0 }.map { |k, v| "#{k} (#{v})" }.join(', ')}"
  puts " Unit Connections: #{@unit_connections}"
  puts " AI: Starting task - #{task['description']} (ID: #{task['task_id']})"

  task['effects']&.each do |effect|
    puts "  Effect: #{effect.inspect}"
    case effect['action']
    when 'deploy_unit'
      unit_to_deploy = effect['unit']
      puts "     Attempting to deploy: #{unit_to_deploy}. Found in inventory: #{@remaining_inventory.key?(unit_to_deploy) && @remaining_inventory[unit_to_deploy] > 0}"
      deploy_simulated_unit(unit_to_deploy)
    when 'power_on'
      unit_to_power_on = effect['unit']
      power_on_unit(unit_to_power_on)
    when 'set_unit_state'
      unit_to_set_state = effect['unit']
      new_state = effect['state']
      target_resource = effect['target_resource']
      set_unit_state(unit_to_set_state, new_state, target_resource)
    when 'connect_units'
      unit1_name = effect['unit1']
      unit2_name = effect['unit2']
      port1_name = effect['port1']
      port2_name = effect['port2']

      unit1 = @simulated_units[unit1_name]&.first if unit1_name != 'Starship'
      unit2 = @simulated_units[unit2_name]&.first if unit2_name != 'Starship'

      unit1 = @starship if unit1_name == 'Starship'
      unit2 = @starship if unit2_name == 'Starship'

      if unit1.nil? && unit1_name != 'Starship'
        puts "     Warning: Could not find unit to connect: #{unit1_name}"
        next
      end
      if unit2.nil? && unit2_name != 'Starship'
        puts "     Warning: Could not find unit to connect: #{unit2_name}"
        next
      end

      next unless unit1 && unit2

      port1_object = get_port(unit1, port1_name)
      port2_object = get_port(unit2, port2_name) # Directly get port on unit2

      if port1_object && port2_object
        unit1_id = unit1.is_a?(Hash) ? unit1[:id] : unit1.id
        unit2_id = unit2.is_a?(Hash) ? unit2[:id] : unit2.id

        puts "     Connected #{unit1.is_a?(Hash) ? unit1[:name] : unit1.name} (ID: #{unit1_id}) port #{port1_object[:name]} to #{unit2.is_a?(Hash) ? unit2[:name] : unit2.name} (ID: #{unit2_id}) port #{port2_object[:name]}"
        @unit_connections[unit1_id] ||= {}
        @unit_connections[unit1_id][port1_object[:name]] = { connected_to: unit2_id, port: port2_object[:name] }
        @unit_connections[unit2_id] ||= {}
        @unit_connections[unit2_id][port2_object[:name]] = { connected_to: unit1_id, port: port1_object[:name] }
      else
        puts "     Warning: Could not find ports to connect #{unit1_name}:#{port1_name} and #{unit2_name}:#{port2_name}"
      end
    when 'transfer_resource'
      source_unit_name = effect['source_unit']
      target_unit_name = effect['target_unit']
      resource = effect['resource']
      amount = effect['amount']
      source_storage = effect['source_storage']

      source_unit = @simulated_units[source_unit_name]&.first
      target_unit = if target_unit_name == 'Starship/Methane Tank'
                      @starship.base_units.find_by(unit_type: 'methane_tank')
                    else
                      @simulated_units[target_unit_name]&.first
                    end

      if source_unit && target_unit
        puts "     Transferring #{amount} #{resource} from #{source_unit_name}/#{source_storage} to #{target_unit_name}"
        # In a real simulation, you'd update resource levels here
      else
        puts "     Warning: Could not find source or target unit for resource transfer."
      end
    end
  end

  puts " AI: Completing task - #{task['description']} (ID: #{task['task_id']})"
  @simulation_time += 1
end

puts "\n--- Simulation End ---"
puts "Final Simulated Units: #{@simulated_units.transform_values(&:count)}"
puts "Final Unit Connections: #{@unit_connections}"
puts "Remaining Inventory: #{@remaining_inventory.select { |_, count| count > 0 }.map { |k, v| "#{k} (#{v})" }.join(', ')}"