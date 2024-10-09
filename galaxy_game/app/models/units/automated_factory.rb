# app/models/automated_factory.rb
module Units
  class AutomatedFactory < BaseUnit
    validates :product_output, presence: true
    validates :production_rate, presence: true, numericality: { greater_than: 0 }

    def produce_item(inventory)
      # Check if there are enough raw materials
      if resource.has_materials?(product_output[:input], product_output[:amount])
        # Consume raw materials
        resource.remove_materials(product_output[:input], product_output[:amount])
        # Add produced item to inventory
        inventory.add_item(product_output[:output], product_output[:amount] * production_rate)
      else
        # Handle the case where there are not enough materials
        raise "Not enough materials to produce item"
      end
    end

    private

    def resource
      # Assuming there's a method to get the resource manager
      ResourceManager.instance
    end
  end
end
  