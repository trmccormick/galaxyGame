module HasExtraction
    extend ActiveSupport::Concern
  
    included do
      # ✅ FIX: Only validate extraction_rate if the attribute exists
      validates :extraction_rate, numericality: { greater_than: 0 }, allow_nil: true, if: :has_extraction_rate?
    end
  
    def extract_resources(target, amount)
      raise "Invalid target" unless valid_extraction_target?(target)
      raise "Storage full" unless can_store?('raw_material', amount)
  
      actual_extracted = (amount * extraction_efficiency).to_i
      update_inventory({ 'raw_material' => actual_extracted })
    end
  
    private
  
    # ✅ ADD: Method to check if extraction_rate attribute exists
    def has_extraction_rate?
      respond_to?(:extraction_rate)
    end
  
    def valid_extraction_target?(target)
      craft_info['deployment']['deployment_locations'].include?(target)
    end
  
    def extraction_efficiency
      craft_info['extraction_efficiency'] || 1.0
    end
  end
