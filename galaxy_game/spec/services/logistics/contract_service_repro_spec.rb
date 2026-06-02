require 'rails_helper'

RSpec.describe 'Logistics::ContractService repro' do
  let(:provider) { create(:logistics_provider) }
  let(:material) { 'oxygen' }
  let(:quantity) { 100 }

  it 'shows why create_internal_transfer returns nil' do
    from_settlement = create(:base_settlement, name: 'Repro Supplier')
    to_settlement = create(:base_settlement, name: 'Repro Consumer')

    # Ensure both owners are NPC organizations
    npc_org = create(:development_corporation)
    allow(from_settlement).to receive(:owner).and_return(npc_org)
    allow(to_settlement).to receive(:owner).and_return(npc_org)

    # Stub inventories to report sufficient available material
    from_inventory = double('Inventory', current_storage_of: 1000)
    allow(from_settlement).to receive(:inventory).and_return(from_inventory)

    to_inventory = double('Inventory', current_storage_of: 0)
    allow(to_settlement).to receive(:inventory).and_return(to_inventory)

    # Ensure provider lookup returns a provider so fallback path can run
    allow(Logistics::ContractService).to receive(:find_provider).and_return(provider)

    # Check preconditions directly
    valid_pair = Logistics::ContractService.send(:valid_settlement_pair?, from_settlement, to_settlement)
    available = from_settlement.inventory.current_storage_of(material)

    puts "valid_settlement_pair? => #{valid_pair}"
    puts "available => #{available} (needed #{quantity})"

    contract = Logistics::ContractService.create_internal_transfer(from_settlement, to_settlement, material, quantity)

    puts "create_internal_transfer returned: #{contract.inspect}"

    # Assertions to make the repro deterministic and informative
    if !valid_pair
      fail "Early return: invalid settlement pair"
    elsif available < quantity
      fail "Early return: insufficient available (#{available} < #{quantity})"
    else
      expect(contract).to be_present
      expect(contract).to be_persisted
    end
  end
end
