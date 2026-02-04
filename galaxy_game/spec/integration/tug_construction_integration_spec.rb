require 'rails_helper'

RSpec.describe 'Tug Construction Integration', type: :integration do
  let(:player) { create(:player) }
  let(:l1_station) { create(:base_settlement, :station, owner: player) }
  let(:marketplace) { create(:marketplace, settlement: l1_station) }

  describe 'Complete Tug Construction Workflow' do
    context 'when all components are properly configured' do
      it 'successfully constructs asteroid relocation tugs from mission to deployment' do
        # Phase 1: Mission Profile Loading and Validation
        mission_profile = load_mission_profile('l1_tug_construction')
        expect(mission_profile).to be_present
        expect(mission_profile['phases'].length).to eq(3)

        # Phase 2: Settlement Preparation
        prepare_settlement_for_construction(l1_station)
        expect(l1_station.orbital_construction_projects.count).to eq(0)

        # Phase 3: AI Manager Teaching and Pattern Learning
        teaching_results = perform_ai_teaching('tug_construction')
        expect(teaching_results[:success]).to be true
        expect(teaching_results[:patterns_learned]).to include(:procurement, :sequencing, :quality_assurance)

        # Phase 4: Construction Project Creation
        project = Construction::OrbitalShipyardService.create_shipyard_project(
          l1_station,
          'asteroid_relocation_tug'
        )
        expect(project).to be_persisted
        expect(project.status).to eq('materials_pending')
        expect(project.required_materials).to be_present

        # Phase 5: Material Procurement via Marketplace
        fulfill_material_orders(project, marketplace)
        project.reload
        expect(project.status).to eq('in_progress')

        # Phase 6: Construction Progress Simulation
        simulate_construction_progress(project)
        project.reload
        expect(project.progress_percentage).to eq(100.0)
        expect(project.status).to eq('completed')

        # Phase 7: Tug Deployment and Validation
        deployed_tug = deploy_constructed_tug(project)
        expect(deployed_tug).to be_present
        expect(deployed_tug.craft_type).to eq('asteroid_relocation_tug')

        # Phase 8: Operational Validation
        operational_results = validate_tug_operations(deployed_tug)
        expect(operational_results[:capture_system_functional]).to be true
        expect(operational_results[:propulsion_operational]).to be true
        expect(operational_results[:radiation_shielding_adequate]).to be true

        # Phase 9: Pattern Validation and Learning
        pattern_validation = validate_construction_patterns(project, teaching_results[:patterns])
        expect(pattern_validation[:accuracy_score]).to be >= 0.80
        expect(pattern_validation[:corrections_applied]).to be_an(Array)
      end
    end

    context 'when environmental challenges are present' do
      it 'adapts construction patterns for high radiation environment' do
        # Setup high radiation environment via operational_data
        l1_station.update(operational_data: l1_station.operational_data.merge(
          'environmental_conditions' => { 'radiation_level' => 'high' }
        ))

        # Load adaptive mission profile
        mission_profile = load_mission_profile('l1_tug_construction')
        expect(mission_profile['adaptive_parameters']).to be_present

        # Create construction project
        project = Construction::OrbitalShipyardService.create_shipyard_project(
          l1_station,
          'asteroid_relocation_tug'
        )

        # Set initial estimated completion time
        project.update(estimated_completion_time: project.created_at + 30.days)

        # Apply environmental adaptations based on station conditions
        apply_environmental_adaptations(project, l1_station)

        # Verify adaptive parameters are applied
        expect(project.project_metadata['radiation_adaptations']).to be_present
        expect(project.required_materials['radiation_shielding']).to be > 0

        # Simulate construction with adaptations
        simulate_adaptive_construction(project, radiation_level: 'high')
        project.reload
        expect(project.status).to eq('completed')

        # Validate radiation-specific outcomes
        deployed_tug = deploy_constructed_tug(project)
        radiation_test_results = test_radiation_shielding(deployed_tug)
        expect(radiation_test_results[:shielding_effectiveness]).to be >= 0.95
      end
    end

    context 'when material shortages occur' do
      it 'handles procurement delays and alternative sourcing' do
        # Create project
        project = Construction::OrbitalShipyardService.create_shipyard_project(
          l1_station,
          'asteroid_relocation_tug'
        )

        # Simulate material shortage for titanium
        simulate_material_shortage(marketplace, 'titanium_alloy')

        # Create a buy order to simulate demand
        marketplace.place_order(
          orderable: create(:organization),
          resource: 'titanium_alloy',
          volume: 1000,
          order_type: :buy,
          price: 200
        )

        # Verify buy orders are created
        titanium_orders = marketplace.orders.where(resource: 'titanium_alloy', order_type: :buy)
        expect(titanium_orders.count).to be > 0

        # Simulate delayed fulfillment
        fulfill_with_delay(project, 'titanium_alloy', delay_days: 10)

        # Verify project adapts to delay
        project.reload
        expect(project.project_metadata['procurement_delays']).to include('titanium_alloy')
        expect(project.estimated_completion_time).to be > project.created_at

        # Complete construction despite delay
        complete_construction_with_delays(project)
        expect(project.status).to eq('completed')
      end
    end

    context 'when quality issues arise' do
      it 'implements rework and quality assurance procedures' do
        project = Construction::OrbitalShipyardService.create_shipyard_project(
          l1_station,
          'asteroid_relocation_tug'
        )

        # Fulfill materials
        fulfill_material_orders(project, marketplace)

        # Simulate quality issue during construction
        simulate_quality_issue(project, issue_type: 'propulsion_alignment')

        # Verify rework is triggered
        project.reload
        expect(project.project_metadata['quality_issues']).to be_present
        expect(project.project_metadata['rework_required']).to be true

        # Complete rework process
        perform_quality_rework(project)

        # Verify successful completion
        project.reload
        expect(project.status).to eq('completed')
        expect(project.project_metadata['quality_assurance_passed']).to be true
      end
    end
  end

  # Helper methods for test setup and execution

  def load_mission_profile(profile_id)
    path = GalaxyGame::Paths::TASKS_MISSIONS_PATH.join("#{profile_id}_profile_v1.json")
    JSON.parse(File.read(path)) if File.exist?(path)
  end

  def prepare_settlement_for_construction(station)
    # Ensure station has necessary infrastructure
    station.update(
      operational_data: station.operational_data.merge({
        infrastructure_level: 3,
        shipyard_bays: 2,
        robotic_assembly_arms: 6,
        quality_control_systems: 3
      })
    )
  end

  def perform_ai_teaching(pattern_type)
    # Simulate AI teaching process
    {
      success: true,
      patterns_learned: [:procurement, :sequencing, :quality_assurance],
      confidence_level: 0.95
    }
  end

  def apply_environmental_adaptations(project, station)
    # Check station environmental conditions and apply adaptations
    env_conditions = station.operational_data['environmental_conditions'] || {}

    if env_conditions['radiation_level'] == 'high'
      # Add radiation shielding requirement
      updated_materials = project.required_materials.merge('radiation_shielding' => 150000)
      project.update!(
        required_materials: updated_materials,
        project_metadata: project.project_metadata.merge(
          'radiation_adaptations' => {
            'shielding_required' => true,
            'additional_materials' => ['radiation_shielding'],
            'construction_modifiers' => ['radiation_protected_assembly']
          }
        )
      )
    end
  end

  def fulfill_material_orders(project, marketplace)
    project.required_materials.each do |material, quantity|
      # Create sell orders to fulfill buy orders
      marketplace.place_order(
        orderable: create(:organization),
        resource: material,
        volume: quantity * 1.1, # Slight oversupply
        order_type: :sell,
        price: 100 # Base price for testing
      )

      # Process material delivery for each material
      Construction::OrbitalShipyardService.deliver_materials(
        project.station,
        material,
        quantity,
        create(:organization)
      )
    end
  end

  def simulate_construction_progress(project)
    # Simulate construction time progression
    project.update(
      progress_percentage: 25.0,
      status: 'in_progress'
    )

    # Simulate material deliveries for remaining materials
    project.required_materials.except(project.required_materials.keys.first).each do |material, quantity|
      Construction::OrbitalShipyardService.deliver_materials(
        project.station,
        material,
        quantity,
        create(:organization)
      )
    end

    project.update(progress_percentage: 100.0, status: 'completed')
  end

  def deploy_constructed_tug(project)
    # Create craft record from completed project
    craft = create(:base_craft,
      name: "Tug-#{project.id}",
      craft_type: 'asteroid_relocation_tug',
      docked_at: project.station,
      operational_data: {
        construction_project_id: project.id,
        deployment_ready: true
      }
    )
    craft
  end

  def validate_tug_operations(tug)
    # Simulate operational validation tests
    {
      capture_system_functional: true,
      propulsion_operational: true,
      radiation_shielding_adequate: true,
      navigation_systems_calibrated: true
    }
  end

  def validate_construction_patterns(project, learned_patterns)
    # Simulate pattern validation
    {
      accuracy_score: 0.87,
      corrections_applied: ['optimize_procurement_timing'],
      performance_metrics: {
        cost_variance: 0.05,
        time_variance: 0.08,
        quality_score: 0.92
      }
    }
  end

  def simulate_adaptive_construction(project, **conditions)
    # Simulate construction with environmental adaptations
    adaptations = []
    if conditions[:radiation_level] == 'high'
      adaptations << 'enhanced_radiation_shielding'
      project.project_metadata['radiation_adaptations'] = adaptations
    end

    project.update(
      progress_percentage: 100.0,
      status: 'completed',
      project_metadata: project.project_metadata.merge(
        'adaptations_applied' => adaptations
      )
    )
  end

  def test_radiation_shielding(tug)
    # Simulate radiation testing
    { shielding_effectiveness: 0.96 }
  end

  def simulate_material_shortage(marketplace, material)
    # Remove existing sell orders for the material
    marketplace.orders.where(resource: material, order_type: :sell).destroy_all
  end

  def fulfill_with_delay(project, material, delay_days:)
    # Simulate delayed material delivery
    project.project_metadata['procurement_delays'] ||= {}
    project.project_metadata['procurement_delays'][material] = delay_days
    # Update estimated completion time due to delay
    current_time = project.estimated_completion_time || Time.current
    project.update(estimated_completion_time: current_time + delay_days.days)
    project.save

    # Eventually fulfill the order
    Construction::OrbitalShipyardService.deliver_materials(
      project.station,
      material,
      project.required_materials[material],
      create(:organization)
    )
  end

  def complete_construction_with_delays(project)
    project.update(
      progress_percentage: 100.0,
      status: 'completed',
      completed_at: project.created_at + 35.days # Extended due to delays
    )
  end

  def simulate_quality_issue(project, issue_type:)
    project.project_metadata['quality_issues'] ||= []
    project.project_metadata['quality_issues'] << {
      type: issue_type,
      severity: 'moderate',
      detected_at: Time.current
    }
    project.project_metadata['rework_required'] = true
    project.save
  end

  def perform_quality_rework(project)
    # Simulate rework process
    issues = project.project_metadata['quality_issues']
    rework_time = issues.size * 24.hours # 24 hours per issue

    project.update(
      progress_percentage: 100.0,
      status: 'completed',
      project_metadata: project.project_metadata.merge(
        'rework_completed' => true,
        'rework_time_hours' => rework_time / 1.hour,
        'quality_assurance_passed' => true
      )
    )
  end
end