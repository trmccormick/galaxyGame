module Craft
  class Harvester < BaseCraft
    include HasExtraction
    include Crafts::HasProcessing  # Updated to use namespaced concern

    store_accessor :operational_data, :extraction_rate

    validates :extraction_rate, numericality: { greater_than: 0 }

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


