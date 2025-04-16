require 'rails_helper'

RSpec.describe ProcessingService, type: :service do
  # Create the player with an inventory
  let!(:owner) { create(:player) }
  
  # Create location
  let!(:celestial_body) { create(:celestial_body, :luna) }
  let!(:celestial_location) do
    create(:celestial_location, 
      celestial_body: celestial_body,
      coordinates: "45.00°N 125.00°E",
      name: "Shackleton Base"
    )
  end
  
  # Set up player's location and inventory through a settlement
  let!(:settlement) {
    create(:base_settlement, 
      owner: owner, 
      location: celestial_location
    )
  }
  
  # Get the inventory directly from the settlement
  let!(:inventory) { settlement.inventory }
  
  # Make sure the player can find its inventory through the settlement
  before do
    # Explicitly associate the player with the inventory via mock
    allow(owner).to receive(:inventory).and_return(inventory)
    
    # Set the player's active location
    owner.update!(active_location: celestial_location.name)
    
    # Add required materials to inventory
    create_test_materials
    
    # Add funds to account
    owner.account.deposit(99_000.0, "Testing funds")
    
    # Mock the blueprint service
    setup_blueprint_service
    
    # Mock the Item.create! calls to prevent validation issues
    mock_item_creation
  end
  
  def mock_item_creation
    allow(Item).to receive(:create!).and_return(
      instance_double("Item", name: "Unassembled Algae Bioreactor", amount: 1),
      instance_double("Item", name: "Scrap Metal", amount: 50)
    )
  end
  
  def setup_blueprint_service
    blueprint_service = instance_double(Lookup::BlueprintLookupService)
    allow(Lookup::BlueprintLookupService).to receive(:new).and_return(blueprint_service)
    allow(blueprint_service).to receive(:find_blueprint).with("Algae Bioreactor Blueprint").and_return(test_blueprint)
  end
  
  def create_test_materials
    # Bypass validation for test items
    allow_any_instance_of(Item).to receive(:validate_item_exists).and_return(true)
    
    # Create items using factory_bot
    ["Steel", "Concrete", "Plastic", "Water", "Energy Cell"].each do |name|
      create(:item, 
        name: name, 
        amount: name == "Energy Cell" ? 50 : 500, 
        inventory: inventory, 
        owner: owner
      )
    end
  end
  
  def test_blueprint
    {
      'name' => "Algae Bioreactor Blueprint",
      'cost_gcc' => 5_000,  
      'materials' => [
        { 'name' => 'Steel', 'amount' => 100 },
        { 'name' => 'Concrete', 'amount' => 150 },
        { 'name' => 'Plastic', 'amount' => 50 },
        { 'name' => 'Water', 'amount' => 200 },
        { 'name' => 'Energy Cell', 'amount' => 50 }
      ],
      'units' => [
        { 'name' => 'Algae Bioreactor', 'type' => 'unit', 'quantity' => 1 }
      ],
      'byproducts' => [
        { 'material' => 'Scrap Metal', 'amount' => 50 }
      ]
    }
  end
  
  let(:service) { ProcessingService.new(owner, "Algae Bioreactor Blueprint") }
  
  describe '#process' do
    context 'when owner has sufficient resources and funds' do
      it 'successfully processes the blueprint and creates unassembled items' do
        result = service.process
        expect(result).to include("Production complete")
      end
    end

    context 'when owner does not have enough resources' do
      before do
        # Find the item and update its amount
        item = inventory.items.find_by(name: "Steel")
        item.update(amount: 50) if item
      end

      it 'returns an error when resources are insufficient' do
        expect {
          service.process
        }.to raise_error(RuntimeError, /Insufficient resources: Steel/)
      end
    end

    context 'when owner does not have enough GCC' do
      before do
        owner.account.withdraw(95_000.0, "Testing insufficient funds")
      end

      it 'raises an error when GCC is insufficient' do
        expect {
          service.process
        }.to raise_error(RuntimeError, "Insufficient GCC")
      end
    end
  end
end






