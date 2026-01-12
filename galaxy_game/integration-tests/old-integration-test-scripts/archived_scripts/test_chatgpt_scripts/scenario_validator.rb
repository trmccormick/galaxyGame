require 'json'

module TestScripts
  class ScenarioValidator
    def initialize(scenario_file_path)
      @scenario_data = JSON.parse(File.read(scenario_file_path))
      @simulated_units = {}
      @inventory = {}
      @current_power = 0
      @time = 0
    end

    def run
      puts "\n--- AI Manager: #{@scenario_data['title']} ---\n\n"
      load_inventory
      puts "Initial Inventory:"
      @inventory.each { |name, count| puts "  #{name} (Count: #{count})" }

      puts "\nSimulation Begins:\n"

      @scenario_data['tasks'].each do |task|
        puts "\n[Hour #{@time}] AI: Starting task - #{task['description']}"

        task['effects'].each do |effect|
          apply_effect(effect)
        end

        if task['expected_outcomes']
          validate_expectations(task['expected_outcomes'])
        end

        @time += 1
      end

      puts "\n--- Simulation End ---"
    end

    private

    def load_inventory
      @inventory = Hash.new(0)
      @scenario_data['inventory']&.each do |item|
        @inventory[item] += 1
      end
    end

    def apply_effect(effect)
      action = effect['action']
      case action
      when 'deploy_unit'
        deploy_unit(effect['unit'])
      when 'power_on'
        power_on_unit(effect['unit'])
      when 'set_state'
        set_unit_state(effect['unit'], effect['state'])
      else
        puts "  ⚠️ Unknown action: #{action}"
      end
    end

    def deploy_unit(unit_name)
      if @inventory[unit_name].to_i <= 0
        puts "  ❌ Error: #{unit_name} not found in inventory!"
        return
      end

      @inventory[unit_name] -= 1
      unit_id = "#{unit_name.downcase.gsub(" ", "_")}_#{@simulated_units.length}"
      @simulated_units[unit_name] ||= []
      @simulated_units[unit_name] << {
        id: unit_id,
        name: unit_name,
        state: 'idle',
        power_on: false
      }
      puts "  ✅ Deployed simulated unit: #{unit_name} (ID: #{unit_id})"
    end

    def power_on_unit(unit_name)
      unit = find_unit(unit_name)
      return puts "  ❌ No unit named #{unit_name} found!" unless unit

      unit[:power_on] = true
      puts "  🔌 Powered on unit: #{unit[:name]} (ID: #{unit[:id]})"
    end

    def set_unit_state(unit_name, new_state)
      unit = find_unit(unit_name)
      return puts "  ❌ No unit named #{unit_name} found!" unless unit

      unit[:state] = new_state
      puts "  🔁 Set state of #{unit[:name]} to: #{new_state}"
    end

    def find_unit(name)
      @simulated_units[name]&.last
    end

    def validate_expectations(expectations)
      expectations.each do |key, value|
        case key
        when 'unit_powered'
          unit = find_unit(value)
          if unit&.dig(:power_on)
            puts "  ✅ Expectation passed: #{value} is powered on"
          else
            puts "  ❌ Expectation failed: #{value} is NOT powered on"
          end
        when 'unit_state'
          value.each do |unit_name, expected_state|
            unit = find_unit(unit_name)
            if unit.nil?
              puts "  ❌ Expectation failed: No unit named #{unit_name} found!"
            elsif unit[:state] == expected_state
              puts "  ✅ Expectation passed: #{unit_name} is in '#{expected_state}' state"
            else
              puts "  ❌ Expectation failed: #{unit_name} should be '#{expected_state}', but was '#{unit[:state]}'"
            end
          end
        else
          puts "  ⚠️ Unknown expectation type: #{key}"
        end
      end
    end
  end
end
