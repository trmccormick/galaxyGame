module Crafts
  module HasProcessing
    extend ActiveSupport::Concern
  
    def process_resources
      raw_material = inventory.items.find_by(name: 'raw_material')
      return unless raw_material&.amount&.positive?
  
      conversion_rate = craft_info['processing_conversion_rate'] || 1.0
      processed_amount = (raw_material.amount * conversion_rate).to_i
  
      update_inventory({ 'raw_material' => -processed_amount, 'refined_material' => processed_amount })
    end
  end
end