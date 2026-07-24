module Craft
  class Harvester < BaseCraft
    include HasExtraction
    include Crafts::HasProcessing  # Updated to use namespaced concern

    delegate :source_body, to: :orbiting_celestial_body, allow_nil: true

    store_accessor :operational_data, :extraction_rate

    validates :extraction_rate, numericality: { greater_than: 0 }

    #---------------------------------------------------------------------------
    # Exhaust Emissions — propellant type → atmospheric impact
    #---------------------------------------------------------------------------

    # Exhaust gas composition by propellant type (mass fractions)
    # Based on real combustion stoichiometry:
    # CH4 + 2O2 -> CO2 + 2H2O
    # LH2 + 0.5O2 -> H2O
    # N2O4 + 2UDMH -> NO2 + N2 + H2O (simplified hypergolic)
    EXHAUST_COMPOSITION = {
      'CH4_O2'     => { 'CO2' => 0.55, 'H2O' => 0.45 },   # Methane/oxygen (SpaceX Raptor)
      'LH2_LOX'    => { 'H2O' => 1.0 },                     # Liquid hydrogen/oxygen (SSME)
      'HYPERGOLIC' => { 'NO2' => 0.67, 'N2' => 0.33 }       # N2O4/UDMH (traditional)
    }.freeze

    # Exhaust mass multiplier: kg of exhaust per kg of propellant consumed
    # Based on real stoichiometry:
    # CH4_O2: 16g CH4 + 64g O2 -> 44g CO2 + 36g H2O = 80g products / 80g reactants = 1.0
    # LH2_LOX: 4g H2 + 32g O2 -> 36g H2O = 36g / 36g = 1.0
    # HYPERGOLIC: ~1:1 mass ratio (UDMH + N2O4)
    EXHAUST_RATE = {
      'CH4_O2'     => 1.0,   # Mass conserved in combustion (80g -> 80g)
      'LH2_LOX'    => 1.0,   # Mass conserved in combustion (36g -> 36g)
      'HYPERGOLIC' => 1.0    # ~1:1 mass ratio
    }.freeze

    # Primary function of the harvester is to extract resources
    def extract_resources(target_body, amount)
      raise "Invalid target" unless valid_extraction_target?(target_body)
      ensure_inventory
      raise "Storage full" unless can_store?('Regolith', amount)

      # Extract regolith instead of generic raw_material
      actual_extracted = (amount * extraction_efficiency).to_i
      update_inventory({ 'Regolith' => actual_extracted })
    end

    # Check if the harvester can store a given material and amount
    def can_store?(material_name, amount)
      return false unless inventory

      # For now, assume unlimited storage capacity
      # TODO: Implement actual capacity checking based on craft size and storage modules
      true
    end

    # Process extracted materials into refined resources
    def process_resources
      inventory.items.each do |item|
        next unless processable_material?(item.name)

        processed_amount = calculate_processing(item.amount)
        item.update!(amount: item.amount - processed_amount)

        refined_item = inventory.items.find_or_initialize_by(name: 'Processed Regolith') do |item|
          item.owner = player || self
          item.storage_method = 'bulk_storage'
          item.material_type = :processed_material
        end
        refined_item.amount += processed_amount
        refined_item.save!
      end
    end

    # Function to harvest atmospheric gases or dust
    def harvest_atmosphere(celestial_body, gas_name: nil, dust_amount: nil)
      atmosphere = celestial_body.atmosphere
      raise "No atmosphere found on target body" unless atmosphere

      # Handle gas harvesting
      if gas_name && gas_name.present?
        harvest_gas(atmosphere, gas_name, dust_amount)
      end

      # Handle dust harvesting
      if dust_amount && dust_amount.to_f > 0
        harvest_dust(atmosphere, dust_amount)
      end
    end

    # Apply exhaust emissions from harvester operation to the source body's atmosphere.
    # Called during extraction loops to track atmospheric impact of propellant consumption.
    # Follows the same pattern as volcanic emissions in GeosphereSimulationService.
    #
    # Exhaust composition based on real Starship Raptor stoichiometry:
    # CH4 + 2O2 -> CO2 + 2H2O (16g CH4 + 64g O2 -> 44g CO2 + 36g H2O)
    # Mass fractions: CO2 = 44/80 = 0.55, H2O = 36/80 = 0.45
    def apply_exhaust_to_atmosphere!
      return unless source_body&.atmosphere&.present?
      return unless operational?

      propellant_type = (operational_data || {})['propellant_type'] || 'CH4_O2'
      
      # Default to CH4_O2 if unknown propellant type
      return unless EXHAUST_COMPOSITION.key?(propellant_type)
      
      exhaust_composition = EXHAUST_COMPOSITION[propellant_type]
      exhaust_rate = EXHAUST_RATE[propellant_type]

      # Propellant consumption derived from extraction rate.
      # For HLT mk1 (Starship Raptor-class): methane_engine + lox_tank
      # O/F ratio ~3.5:1 (oxygen-rich), total propellant per kg of work scales with extraction_rate
      # Using 0.1 as a conservative operational factor (10% of extraction rate as propellant mass)
      # This is still a design parameter — real propellant tracking requires craft blueprint data
      propellant_consumed = (extraction_rate || 100) * 0.1

      exhaust_mass_total = propellant_consumed * exhaust_rate

      exhaust_composition.each do |gas_name, fraction|
        gas_mass = exhaust_mass_total * fraction
        source_body.atmosphere.add_gas(gas_name, gas_mass)

        Rails.logger.info "[Exhaust: #{gas_name}_#{SecureRandom.hex(4)}] " \
          "Harvester #{id} on #{source_body.name}: +#{gas_mass.round(2)}kg"
      end
    end

    # Check if the harvester is currently operational
    def operational?
      (status || '').in?(['active', 'operational', 'harvesting'])
    end

    private

    def processable_material?(material_name)
      material_name == 'Regolith'
    end

    def calculate_processing(amount)
      # Process 80% of raw material into refined material
      (amount * 0.8).to_i
    end

    def harvest_gas(atmosphere, gas_name, amount)
      # Use AtmosphericHarvester service for gas extraction
      harvester = AtmosphericHarvester.new(celestial_body, self)
      harvester.harvest_gases(gas_name, amount)
      log_harvest_event(gas_name, amount)
    end

    def harvest_dust(atmosphere, amount)
      # Use AtmosphericHarvester service for dust extraction
      harvester = AtmosphericHarvester.new(celestial_body, self)
      harvester.harvest_dust(amount)
      log_harvest_event("dust", amount)
    end

    def log_harvest_event(material_name, amount)
      Rails.logger.info("Harvested #{amount} of #{material_name} from #{@celestial_body.name}")
    end
  end
end


