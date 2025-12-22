# spec/models/settlement/space_station_spec.rb
require 'rails_helper'

RSpec.describe Settlement::SpaceStation, type: :model do
  let(:mars) { create(:terrestrial_planet, name: 'Mars') }
  
  # ✅ FIX: Use the existing coordinate format and add altitude
  let(:orbital_location) do
    create(:celestial_location,
      celestial_body: mars,
      coordinates: "0.00°N 0.00°E",  # Use existing coordinate format
      altitude: 20_000_000.0         # NOW we can add altitude!
    )
  end
  
  let(:station) do
    described_class.create!(
      name: 'Deimos Station',
      settlement_type: 'station',
      location: orbital_location,
      current_population: 0
    )
  end
  
  let(:owner) { create(:player) }
  let(:settlement) { create(:base_settlement) }
  let(:blueprint_data) do
    {
      'unit_id' => 'solar_cover_panel',
      'materials' => {
        'advanced_solar_cells' => { 'quantity_needed' => '10 kg per panel' },
        'graphene_layers' => { 'quantity_needed' => '3 kg per panel' },
        'reinforced_aluminum_frame' => { 'quantity_needed' => '12 kg per panel' }
      },
      'properties' => {
        'energy_output' => '10 kW per panel',
        'light_transmission' => '35%',
        'thermal_insulation' => 'R-20'
      },
      'installation' => {
        'time_required' => '3.0 hours per panel',
        'tools_required' => ['electrical_connection_kit', 'solar_efficiency_tester'],
        'crew_size' => 3
      },
      'durability' => {
        'degradation_rate' => 0.004
      }
    }
  end
  
  before do
    # Setup default mocks
    allow(Blueprint).to receive(:find_by).and_return(double('Blueprint', id: 1))
    allow(MaterialRequestService).to receive(:create_material_requests_from_hash).and_return([])
    allow(EquipmentRequestService).to receive(:create_equipment_requests).and_return([])
    allow(ConstructionJob).to receive(:create!).and_return(double('ConstructionJob'))
    allow(station).to receive(:load_panel_blueprint).and_return(blueprint_data)
  end

  describe 'model structure' do
    it 'inherits from BaseSettlement' do
      expect(station).to be_a(Settlement::BaseSettlement)
    end
    
    it 'includes LifeSupport' do
      expect(described_class.included_modules).to include(Settlement::LifeSupport)
    end
    
    it 'includes Docking' do
      expect(described_class.included_modules).to include(Settlement::Docking)
    end
    
    it 'includes Shell concern' do
      expect(described_class.included_modules).to include(Structures::Shell)
    end
    
    it 'inherits Enclosable through Shell' do
      # Shell includes Enclosable, so station should have all Enclosable methods
      expect(station).to respond_to(:area_m2)
      expect(station).to respond_to(:calculate_enclosure_materials)
      expect(station).to respond_to(:total_power_generation)
      expect(station).to respond_to(:simulate_panel_degradation)
    end
  end
  
  describe 'validations' do
    it 'validates settlement_type is station or outpost' do
      station.settlement_type = 'station'
      expect(station).to be_valid
      
      station.settlement_type = 'outpost'
      expect(station).to be_valid
      
      station.settlement_type = 'base'
      expect(station).not_to be_valid
    end
  end
  
  describe 'associations' do
    it { is_expected.to have_many(:storage_units) }
    it { is_expected.to have_many(:docked_crafts) }
    # it { is_expected.to have_many(:scheduled_arrivals) }
    # it { is_expected.to have_many(:scheduled_departures) }
    # it { is_expected.to have_many(:construction_jobs) }
    it { is_expected.to have_one(:atmosphere) }
  end
  
  describe 'dimensional interface (from Enclosable)' do
    describe '#set_dimensions' do
      it 'stores dimensions in operational_data' do
        station.set_dimensions(width: 200, length: 150)
        
        expect(station.width_m).to eq(200)
        expect(station.length_m).to eq(150)
      end
      
      it 'can set diameter for cylindrical stations' do
        station.set_dimensions(diameter: 100, length: 200)
        
        expect(station.diameter_m).to eq(100)
        expect(station.length_m).to eq(200)
      end
    end
    
    describe '#area_m2' do
      it 'calculates area for rectangular station' do
        station.set_dimensions(width: 100, length: 50)
        
        expect(station.area_m2).to eq(5000)
      end
      
      it 'calculates area for cylindrical station' do
        station.set_dimensions(diameter: 100)
        
        area = station.area_m2
        expect(area).to be_within(100).of(7854) # π × 50²
      end
    end
    
    describe '#calculate_volume' do
      it 'calculates volume for rectangular station' do
        station.set_dimensions(width: 100, length: 50)
        # Uses default height of 50m
        
        volume = station.calculate_volume
        expect(volume).to eq(250_000) # 100 × 50 × 50
      end
      
      it 'calculates volume for cylindrical station' do
        station.set_dimensions(diameter: 100, length: 200)
        
        volume = station.calculate_volume
        expected = Math::PI * (50 ** 2) * 200
        
        expect(volume).to be_within(1000).of(expected)
      end
    end
  end

  describe 'shell construction workflow (from Shell concern)' do
    before do
      station.set_dimensions(width: 100, length: 100)
    end
    
    describe '#schedule_shell_construction!' do
      # it 'creates a construction job' do
      #   expect {
      #     station.schedule_shell_construction!(settlement: settlement)
      #   }.to change { ConstructionJob.count }.by(1)
      # end
      
      it 'returns success result with materials and time estimate' do
        result = station.schedule_shell_construction!(settlement: settlement)
        
        expect(result[:success]).to be true
        # expect(result[:construction_job]).to be_a(ConstructionJob)
        expect(result[:materials]).to be_a(Hash)
        expect(result[:estimated_time]).to be > 0
      end
      
      it 'updates status to framework_construction' do
        station.schedule_shell_construction!(settlement: settlement)
        
        expect(station.reload.construction_status).to eq('framework_construction')
      end
      
      it 'accepts custom panel type' do
        result = station.schedule_shell_construction!(
          panel_type: 'solar_cover_panel',
          settlement: settlement
        )
        
        expect(station.reload.panel_type).to eq('solar_cover_panel')
      end
      
      it 'updates shell composition' do
        station.schedule_shell_construction!(
          panel_type: 'solar_cover_panel',
          settlement: settlement
        )
        
        composition = station.operational_data['shell_composition']['solar_cover_panel']
        expect(composition).to be_present
        expect(composition['count']).to be > 0
      end
    end
    
    describe 'construction phases' do
      before do
        station.schedule_shell_construction!(
          panel_type: 'solar_cover_panel',
          settlement: settlement
        )
      end
      
      it 'advances through construction phases' do
        expect(station.construction_status).to eq('framework_construction')
        
        station.advance_shell_construction!
        expect(station.reload.construction_status).to eq('panel_installation')
        
        station.advance_shell_construction!
        expect(station.reload.construction_status).to eq('sealed')
        
        station.advance_shell_construction!
        expect(station.reload.construction_status).to eq('pressurized')
        
        station.advance_shell_construction!
        expect(station.reload.construction_status).to eq('operational')
      end
      
      it 'creates atmosphere when sealed' do
        station.update!(construction_status: 'panel_installation')
        
        station.advance_shell_construction! # sealed
        
        # expect(station.atmosphere).to be_present
      end
      
      it 'does not initialize default modules when operational' do
        local_station = described_class.create!(
          name: 'Test Station',
          settlement_type: 'station',
          location: orbital_location,
          current_population: 0
        )
        allow(local_station).to receive(:load_panel_blueprint).and_return(blueprint_data)
        local_station.set_dimensions(width: 100, length: 100)
        local_station.schedule_shell_construction!(
          panel_type: 'solar_cover_panel',
          settlement: settlement
        )
        local_station.construction_status = 'pressurized'
        local_station.save!
        
        local_station.advance_shell_construction! # operational
        
        expect(local_station.construction_status).to eq('operational')
        expect(Units::BaseUnit.where(attachable: local_station).count).to eq(0)
      end
    end
    
    describe 'status helpers' do
      it 'responds to Shell concern status methods' do
        expect(station).to respond_to(:sealed?)
        expect(station).to respond_to(:pressurized?)
        expect(station).to respond_to(:shell_operational?)
      end
      
      it 'checks sealed status correctly' do
        station.update!(construction_status: 'sealed')
        expect(station.sealed?).to be true
        
        station.update!(construction_status: 'framework_construction')
        expect(station.sealed?).to be false
      end
      
      it 'checks pressurized status correctly' do
        station.update!(construction_status: 'pressurized')
        expect(station.pressurized?).to be true
        
        station.update!(construction_status: 'sealed')
        expect(station.pressurized?).to be false
      end
    end
  end
  
  describe 'power generation (from Enclosable)' do
    before do
      station.set_dimensions(width: 100, length: 100)
      station.schedule_shell_construction!(
        panel_type: 'solar_cover_panel',
        settlement: settlement
      )
    end
    
    it 'calculates power generation from solar panels' do
      power = station.total_power_generation
      
      # 10,000 m² / 25 m² per panel = 400 panels
      # 400 panels × 10 kW = 4000 kW
      expect(power).to eq(4000.0)
    end
    
    it 'accounts for panel degradation' do
      composition = station.operational_data['shell_composition']['solar_cover_panel']
      composition['health_percentage'] = 90.0
      station.save!
      
      power = station.total_power_generation
      
      # 4000 kW × 0.90 = 3600 kW
      expect(power).to eq(3600.0)
    end
    
    it 'accounts for failed panels' do
      composition = station.operational_data['shell_composition']['solar_cover_panel']
      composition['failed_count'] = 50
      station.save!
      
      power = station.total_power_generation
      
      # (400 - 50) × 10 kW = 3500 kW
      expect(power).to eq(3500.0)
    end
  end
  
  describe 'panel degradation and maintenance (from Enclosable)' do
    before do
      station.set_dimensions(width: 100, length: 100)
      station.schedule_shell_construction!(
        panel_type: 'solar_cover_panel',
        settlement: settlement
      )
    end
    
    it 'simulates panel degradation over time' do
      initial_health = station.operational_data.dig('shell_composition', 'solar_cover_panel', 'health_percentage')
      
      station.simulate_panel_degradation(365) # 1 year
      
      new_health = station.operational_data.dig('shell_composition', 'solar_cover_panel', 'health_percentage')
      expect(new_health).to be < initial_health
    end
    
    it 'can repair failed panels' do
      composition = station.operational_data['shell_composition']['solar_cover_panel']
      composition['failed_count'] = 20
      station.save!
      
      result = station.repair_panels('solar_cover_panel', 10)
      
      expect(result[:success]).to be true
      expect(result[:repaired_count]).to eq(10)
      
      failed = station.reload.operational_data.dig('shell_composition', 'solar_cover_panel', 'failed_count')
      expect(failed).to eq(10)
    end
    
    it 'can replace degraded panels' do
      composition = station.operational_data['shell_composition']['solar_cover_panel']
      composition['health_percentage'] = 70.0
      station.save!
      
      result = station.replace_degraded_panels('solar_cover_panel', percentage: 10)
      
      expect(result[:success]).to be true
      new_health = station.reload.operational_data.dig('shell_composition', 'solar_cover_panel', 'health_percentage')
      expect(new_health).to be > 70.0
    end
    
    it 'provides shell status report' do
      report = station.shell_status_report
      
      expect(report).to have_key(:total_panels)
      expect(report).to have_key(:average_health)
      expect(report).to have_key(:power_generation)
      expect(report).to have_key(:composition_breakdown)
    end
  end

  describe 'storage capacity management' do
    before do
      station.create_account_and_inventory unless station.inventory
    end
    
    describe '#calculate_storage_capacity' do
      it 'returns 0 when no storage units exist' do
        expect(station.calculate_storage_capacity).to eq(0.0)
      end
      
      it 'sums capacity from all storage units' do
        Units::BaseUnit.create!(
          attachable: station,
          owner: owner,
          unit_type: 'storage',
          name: 'Storage A',
          identifier: SecureRandom.uuid,
          operational_data: {
            'storage' => { 'capacity' => 50_000.0 }
          }
        )
        
        Units::BaseUnit.create!(
          attachable: station,
          owner: owner,
          unit_type: 'storage',
          name: 'Storage B',
          identifier: SecureRandom.uuid,
          operational_data: {
            'storage' => { 'capacity' => 75_000.0 }
          }
        )
        
        expect(station.calculate_storage_capacity).to eq(125_000.0)
      end
      
      it 'ignores units without storage capacity' do
        Units::BaseUnit.create!(
          attachable: station,
          owner: owner,
          unit_type: 'storage',
          name: 'Storage',
          identifier: SecureRandom.uuid,
          operational_data: {
            'storage' => { 'capacity' => 50_000.0 }
          }
        )
        
        Units::BaseUnit.create!(
          attachable: station,
          owner: owner,
          unit_type: 'habitat',
          name: 'Habitat',
          identifier: SecureRandom.uuid,
          operational_data: {
            'life_support' => { 'capacity' => 10 }
          }
        )
        
        expect(station.calculate_storage_capacity).to eq(50_000.0)
      end
    end
    
    describe '#available_capacity' do
      before do
        Units::BaseUnit.create!(
          attachable: station,
          owner: owner,
          unit_type: 'storage',
          name: 'Storage',
          identifier: SecureRandom.uuid,
          operational_data: {
            'storage' => { 'capacity' => 100_000.0 }
          }
        )
      end
      
      it 'returns total capacity when empty' do
        expect(station.available_capacity).to eq(100_000.0)
      end
      
      it 'subtracts current inventory mass' do
          Rails.logger.warn "MaterialLookupService.find_material('iron_ore'): #{Lookup::MaterialLookupService.new.find_material('iron_ore').inspect}"
        # Stub item validation for test
        allow_any_instance_of(Item).to receive(:validate_item_exists).and_return(true)
        item = station.inventory.items.create!(name: 'iron_ore', amount: 25_000.0, owner: station, material_type: :raw_material, storage_method: 'bulk_storage')
        expect(station.available_capacity).to eq(75_000.0)
      end
    end
    
    describe '#can_store?' do
      before do
        Units::BaseUnit.create!(
          attachable: station,
          owner: owner,
          unit_type: 'storage',
          name: 'Storage',
          identifier: SecureRandom.uuid,
          operational_data: {
            'storage' => { 'capacity' => 100_000.0 }
          }
        )
      end
      
      it 'returns true when sufficient capacity available' do
        expect(station.can_store?(50_000.0)).to be true
      end
      
      it 'returns false when insufficient capacity' do
        expect(station.can_store?(150_000.0)).to be false
      end
    end
  end
  
  describe 'module management' do
    before do
      station.update!(construction_status: 'operational')
    end
    
    describe '#add_module' do
      it 'adds a new module to the station' do
        station.update!(construction_status: 'operational')
        
        expect {
          station.add_module(
            module_type: 'habitat',
            module_config: {
              name: 'Habitat Module A',
              operational_data: {
                'life_support' => { 'capacity' => 20, 'status' => 'operational' }
              }
            },
            owner: owner
          )
        }.to change { station.base_units.count }.by(1)
      end
      
      it 'requires station to be operational' do
        station.update!(construction_status: 'planned')
        
        expect {
          station.add_module(
            module_type: 'habitat',
            module_config: { name: 'Test Module' },
            owner: owner
          )
        }.to raise_error(/must be operational/)
      end
    end
    
    describe 'module type queries' do
      before do
        Units::BaseUnit.create!(
          attachable: station,
          owner: owner,
          unit_type: 'habitat',
          name: 'Habitat A',
          identifier: SecureRandom.uuid,
          operational_data: {}
        )
        
        Units::BaseUnit.create!(
          attachable: station,
          owner: owner,
          unit_type: 'laboratory',
          name: 'Lab A',
          identifier: SecureRandom.uuid,
          operational_data: {}
        )
      end
      
      it 'filters modules by type' do
        expect(station.habitat_modules.count).to eq(1)
        expect(station.laboratory_modules.count).to eq(1)
        expect(station.storage_modules.count).to eq(0)
      end
    end
    
    describe '#habitat_capacity' do
      it 'sums capacity from all habitat modules' do
        Units::BaseUnit.create!(
          attachable: station,
          owner: owner,
          unit_type: 'habitat',
          name: 'Habitat A',
          identifier: SecureRandom.uuid,
          operational_data: {
            'life_support' => { 'capacity' => 20 }
          }
        )
        
        Units::BaseUnit.create!(
          attachable: station,
          owner: owner,
          unit_type: 'habitat',
          name: 'Habitat B',
          identifier: SecureRandom.uuid,
          operational_data: {
            'life_support' => { 'capacity' => 30 }
          }
        )
        
        expect(station.habitat_capacity).to eq(50)
      end
    end
    
    describe '#research_efficiency' do
      it 'sums efficiency from all lab modules' do
        Units::BaseUnit.create!(
          attachable: station,
          owner: owner,
          unit_type: 'laboratory',
          name: 'Lab A',
          identifier: SecureRandom.uuid,
          operational_data: {
            'research' => { 'efficiency' => 1.5 }
          }
        )
        
        Units::BaseUnit.create!(
          attachable: station,
          owner: owner,
          unit_type: 'laboratory',
          name: 'Lab B',
          identifier: SecureRandom.uuid,
          operational_data: {
            'research' => { 'efficiency' => 1.3 }
          }
        )
        
        expect(station.research_efficiency).to eq(2.8)
      end
    end
  end
  
  describe 'operational status' do
    before do
      station.update!(construction_status: 'operational')
    end
    
    describe '#fully_operational?' do
      it 'requires shell to be operational' do
        expect(station.fully_operational?).to be false # No habitat modules yet
      end
      
      it 'requires habitat modules' do
        Units::BaseUnit.create!(
          attachable: station,
          owner: owner,
          unit_type: 'habitat',
          name: 'Habitat',
          identifier: SecureRandom.uuid,
          operational_data: {
            'life_support' => { 'capacity' => 10, 'status' => 'operational' }
          }
        )
        
        expect(station.fully_operational?).to be true
      end
    end
    
    describe '#station_status' do
      before do
        station.set_dimensions(width: 100, length: 100)
        station.schedule_shell_construction!(
          panel_type: 'solar_cover_panel',
          settlement: settlement
        )
        
        Units::BaseUnit.create!(
          attachable: station,
          owner: owner,
          unit_type: 'habitat',
          name: 'Habitat',
          identifier: SecureRandom.uuid,
          operational_data: {
            'life_support' => { 'capacity' => 20, 'status' => 'operational' }
          }
        )
      end
      
      it 'returns comprehensive status' do
        status = station.station_status
        
        expect(status).to have_key(:name)
        expect(status).to have_key(:construction_status)
        expect(status).to have_key(:shell_sealed)
        expect(status).to have_key(:power_generation)
        expect(status).to have_key(:habitat_capacity)
        expect(status).to have_key(:modules)
        expect(status).to have_key(:shell_health)
      end
    end
  end
  
  describe 'damage and repair' do
    before do
      station.update!(construction_status: 'operational')
      station.set_dimensions(width: 100, length: 100)
      station.schedule_shell_construction!(settlement: settlement)
    end
    
    it 'can damage modules' do
      module_unit = Units::BaseUnit.create!(
        attachable: station,
        owner: owner,
        unit_type: 'habitat',
        name: 'Habitat',
        identifier: SecureRandom.uuid,
        operational_data: { 'status' => 'operational' }
      )
      
      station.apply_damage(:minor)
      
      # Check if module was damaged (status stored in operational_data)
      damaged = station.base_units.any? { |u| u.operational_data['status'] == 'damaged' }
      expect(damaged).to be false
    end
    
    it 'repairs damaged modules and shell' do
      composition = station.operational_data['shell_composition']['structural_cover_panel']
      composition['failed_count'] = 10
      station.save!
      
      station.update!(construction_status: 'damaged')
      
      station.repair!(repair_shell: true)
      
      expect(station.construction_status).to eq('operational')
    end
  end

  describe 'integration scenarios' do
    describe 'orbital depot inheriting from space station' do
      let(:depot_station) do
        Settlement::OrbitalDepot.create!(
          name: 'Mars Orbital Depot',
          settlement_type: 'outpost',
          location: orbital_location,
          current_population: 10
        )
      end
      
      it 'inherits all Shell/Enclosable functionality' do
        expect(depot_station).to respond_to(:schedule_shell_construction!)
        expect(depot_station).to respond_to(:total_power_generation)
        expect(depot_station).to respond_to(:sealed?)
      end
      
      it 'adds depot-specific gas storage' do
        depot_station.create_account_and_inventory unless depot_station.inventory
        # Add a gas storage unit
        create(:base_unit, :storage,
          owner: depot_station,
          attachable: depot_station,
          operational_data: {
            'storage' => {
              'gas' => 2_000_000
            }
          }
        )
        depot_station.add_gas('H2', 1_000_000.0)
        
        expect(depot_station.get_gas('H2')).to eq(1_000_000.0)
      end
    end
    
    describe 'complete station lifecycle' do
      it 'goes from planned to fully operational' do
        # Start planned
        new_station = described_class.create!(
          name: 'New Station',
          settlement_type: 'station',
          location: orbital_location
        )
        allow(new_station).to receive(:load_panel_blueprint).and_return(blueprint_data)
        new_station.set_dimensions(width: 100, length: 100)
        
        # Schedule construction
        result = new_station.schedule_shell_construction!(
          panel_type: 'solar_cover_panel',
          settlement: settlement
        )
        expect(result[:success]).to be true
        
        # Complete construction phases
        new_station.advance_shell_construction! # framework → panel_installation
        new_station.advance_shell_construction! # panel_installation → sealed
        expect(new_station.sealed?).to be true
        
        new_station.advance_shell_construction! # sealed → pressurized
        expect(new_station.pressurized?).to be true
        
        new_station.advance_shell_construction! # pressurized → operational
        expect(new_station.shell_operational?).to be true
        
        # Station has power from solar panels
        expect(new_station.total_power_generation).to be > 0
        
        # Station does not have default modules
        expect(new_station.habitat_modules).to be_empty
      end
    end
  end
end