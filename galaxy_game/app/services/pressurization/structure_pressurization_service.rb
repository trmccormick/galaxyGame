module Pressurization
  class StructurePressurizationService < BasePressurizationService
    def self.pressurize_structure(structure, available_gases = {}, options = {})
      service = new(structure, available_gases, options)
      service.pressurize
    end
    def initialize(structure, available_gases = {}, options = {})
      @structure = structure
      volume = calculate_structure_volume
      
      # Check for depot tanks if no gases provided
      if available_gases.empty? && structure.respond_to?(:settlement)
        available_gases = self.class.source_gases_from_depot_tanks(structure.settlement)
      end
      
      super(volume, available_gases, options)
    end
    
    private
    
    def self.source_gases_from_depot_tanks(settlement)
      gases = {}
      
      # Look for depot tanks in the settlement
      depot_tanks = settlement.structures.where("operational_data->>'structure_type' = ?", 'depot_tank')
      
      depot_tanks.each do |tank|
        tank_data = tank.operational_data || {}
        
        # Check for stored gases
        if tank_data['gas_storage']
          tank_data['gas_storage'].each do |gas_name, amount|
            # Convert to common names used by pressurization service
            common_name = case gas_name
                          when 'O2' then 'oxygen'
                          when 'N2' then 'nitrogen'
                          when 'CO2' then 'carbon_dioxide'
                          else gas_name.downcase
                          end
            
            gases[common_name.to_sym] ||= 0
            gases[common_name.to_sym] += amount
          end
        end
      end
      
      gases
    end
    
    def calculate_structure_volume
      # Get volume from operational_data if available
      return @structure.operational_data['specifications']['interior_volume'] if @structure.operational_data&.dig('specifications', 'interior_volume')
      
      # Otherwise calculate based on structure type
      case @structure.operational_data['structure_type']
      when 'dome'
        diameter = @structure.operational_data&.dig('specifications', 'diameter') || 50
        height = @structure.operational_data&.dig('specifications', 'height') || (diameter / 2)
        # πr²h/2 (hemisphere)
        Math::PI * ((diameter / 2.0) ** 2) * height / 2.0
      when 'module'
        length = @structure.operational_data&.dig('specifications', 'length') || 10
        width = @structure.operational_data&.dig('specifications', 'width') || 10
        height = @structure.operational_data&.dig('specifications', 'height') || 3
        # Simple rectangular volume
        length * width * height
      else
        # Default volume for unknown structure types
        100.0
      end
    end
    
    def verify_sealing
      # Check if all required units for atmosphere containment are installed and functioning
      integrity = @structure.operational_data&.dig('specifications', 'integrity') || 0
      return false if integrity < 90
      
      # Check if the structure has a functional life support system
      has_life_support = @structure.base_units
                                  .where("unit_type LIKE ?", "%life_support%")
                                  .any?
      return false unless has_life_support
      
      # Check airlock functionality if the structure has airlocks
      airlocks = @structure.base_units.where("unit_type LIKE ?", "%airlock%")
      if airlocks.any?
        airlocks_functional = airlocks.all? { |unit| unit.operational_data&.dig('status') == 'functional' }
        return false unless airlocks_functional
      end
      
      true
    end
    
    public
    
    # Override pressurize to use dynamic pressure calculation
    def pressurize
      unless verify_sealing
        return {
          achieved_pressure: 0,
          used_gases: {},
          success: false,
          error: "Structure is not properly sealed",
          available_gases: @available_gases
        }
      end
      
      # Get current gas storage from structure
      current_gases = @structure.operational_data&.dig('gas_storage') || {}
      
      # Add available gases to current gases
      total_gases = current_gases.merge(@available_gases) do |gas, current_mass, available_mass|
        current_mass + available_mass
      end
      
      # Calculate total moles of O2 and N2
      total_moles = 0.0
      ['oxygen', 'nitrogen'].each do |gas|
        mass = total_gases[gas] || 0
        molar_mass = get_molar_mass(gas)
        moles = mass / molar_mass
        total_moles += moles
      end
      
      # Calculate pressure: P = n * R * T / V
      # T = 293K, V = @volume
      @current_pressure = (total_moles * GameConstants::IDEAL_GAS_CONSTANT * 293.0) / @volume
      
      # All available gases are "used"
      used_gases = @available_gases.dup
      @available_gases = {}
      
      # Update structure's gas_storage
      @structure.operational_data ||= {}
      @structure.operational_data['gas_storage'] = total_gases
      
      # Check success
      success = @current_pressure >= @target_pressure * 0.95
      human_breathable = check_human_breathability
      
      result = {
        achieved_pressure: @current_pressure,
        used_gases: used_gases,
        success: success,
        human_breathable: human_breathable,
        error: success ? nil : "Insufficient gas supply",
        available_gases: @available_gases
      }
      
      # Update structure's atmosphere system if pressurization was successful
      if result[:success]
        @structure.operational_data['systems'] ||= {}
        @structure.operational_data['systems']['atmosphere_management'] = {
          'pressure' => result[:achieved_pressure],
          'composition' => result[:used_gases].transform_keys(&:to_s),
          'breathable' => result[:human_breathable],
          'last_updated' => Time.current.to_i
        }
        
        @structure.save
      end
      
      result
    end
  end
end