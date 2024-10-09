class Trade
  attr_accessor :source_colony, :destination_colony

  def initialize(source_colony, destination_colony)
    @source_colony = source_colony
    @destination_colony = destination_colony
  end

  def execute_trade
    # Example trade logic: Transfer resources based on needs and capacities
    resources_to_export = calculate_export_resources
    resources_to_import = calculate_import_resources

    # Update resource counts in both colonies
    update_resources(resources_to_export, resources_to_import)
  end

  private

  def calculate_export_resources
    # Logic to determine what resources the source colony can export
    # Placeholder: Exporting a fixed amount
    {
      oxygen: 100,
      food: 50
    }
  end

  def calculate_import_resources
    # Logic to determine what resources the destination colony needs
    # Placeholder: Importing a fixed amount
    {
      oxygen: 50,
      food: 100
    }
  end

  def update_resources(export_resources, import_resources)
    @source_colony.resources.merge!(export_resources) { |key, old, new| old - new }
    @destination_colony.resources.merge!(import_resources) { |key, old, new| old + new }
    puts "Trade executed between #{@source_colony.name} and #{@destination_colony.name}."
  end
end
