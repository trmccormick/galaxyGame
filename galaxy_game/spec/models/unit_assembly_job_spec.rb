require 'rails_helper'

RSpec.describe UnitAssemblyJob, type: :model do
  let(:player) { create(:player) }
  let(:settlement) { create(:base_settlement, owner: player) }
  
  let(:job) do
    UnitAssemblyJob.create!(
      base_settlement: settlement,  # Use correct association name
      unit_type: 'raptor_engine',
      count: 2,
      status: 'materials_pending',
      specifications: {  # Use specifications not blueprint_data
        'name' => 'Raptor Engine',
        'production_data' => {
          'manufacturing_time_hours' => 4
        }
      }
    )
  end

  describe "associations" do
    it { should belong_to(:base_settlement) }
    it { should have_many(:material_requests) }
  end

  describe "validations" do
    it { should validate_presence_of(:base_settlement) }
    it { should validate_presence_of(:unit_type) }
    it { should validate_presence_of(:count) }
  end

  describe "#settlement delegation" do
    it "delegates settlement to base_settlement" do
      expect(job.settlement).to eq(settlement)
    end
  end

  describe "#materials_gathered?" do
    before do
      job.material_requests.create!(
        material_name: 'Steel',
        quantity_requested: 100,
        status: 'fulfilled_by_player'
      )
      job.material_requests.create!(
        material_name: 'Electronics',
        quantity_requested: 50,
        status: 'pending'
      )
    end

    it "returns false when not all materials are fulfilled" do
      expect(job.materials_gathered?).to be false
    end

    it "returns true when all materials are fulfilled" do
      job.material_requests.update_all(status: 'fulfilled_by_player')
      expect(job.materials_gathered?).to be true
    end

    it "returns true when no material requests exist" do
      job.material_requests.destroy_all
      expect(job.materials_gathered?).to be true
    end
  end

  describe "#start_assembly" do
    before do
      # Add materials to settlement inventory
      settlement.inventory.items.create!(
        name: 'Steel',
        amount: 200,
        owner: player,
        material_type: 'metal'
      )
      
      settlement.inventory.items.create!(
        name: 'Electronics',
        amount: 100,
        owner: player,
        material_type: 'component'
      )
      
      # Create fulfilled material requests
      job.material_requests.create!(
        material_name: 'Steel',
        quantity_requested: 100,
        status: 'fulfilled_by_player'
      )
      job.material_requests.create!(
        material_name: 'Electronics',
        quantity_requested: 50,
        status: 'fulfilled_by_player'
      )
    end

    it "starts assembly when materials are gathered" do
      expect(job.start_assembly).to be true
      
      job.reload
      expect(job.status).to eq('in_progress')
      expect(job.start_date).to be_present
      expect(job.estimated_completion).to be_present
    end

    it "consumes materials from inventory" do
      steel_item = settlement.inventory.items.find_by(name: 'Steel')
      electronics_item = settlement.inventory.items.find_by(name: 'Electronics')
      
      expect { job.start_assembly }.to change { steel_item.reload.amount }.from(200).to(100)
        .and change { electronics_item.reload.amount }.from(100).to(50)
    end

    it "returns false when not materials_pending status" do
      job.update!(status: 'completed')
      expect(job.start_assembly).to be false
    end
  end

  describe "#complete_assembly" do
    before do
      job.update!(status: 'in_progress', start_date: 2.hours.ago)
    end

    it "creates unassembled items in inventory" do
      expect {
        job.complete_assembly
      }.to change { settlement.inventory.items.count }.by(2)
      
      # Check created items
      items = settlement.inventory.items.where(name: 'Unassembled Raptor Engine')
      expect(items.count).to eq(2)
      
      item = items.first
      expect(item.owner).to eq(player)
      expect(item.material_type).to eq('manufactured_goods')
      expect(item.metadata['deployment_data']['unit_type']).to eq('raptor_engine')
    end

    it "marks job as completed" do
      job.complete_assembly
      
      job.reload
      expect(job.status).to eq('completed')
      expect(job.completion_date).to be_present
    end

    it "returns false when not in_progress" do
      job.update!(status: 'materials_pending')
      expect(job.complete_assembly).to be false
    end
  end

  describe "scopes" do
    let!(:pending_job) { create(:unit_assembly_job, status: 'pending') }
    let!(:materials_pending_job) { create(:unit_assembly_job, status: 'materials_pending') }
    let!(:in_progress_job) { create(:unit_assembly_job, status: 'in_progress') }
    let!(:completed_job) { create(:unit_assembly_job, status: 'completed') }

    describe ".active" do
      it "returns jobs that are not completed/failed/canceled" do
        active_jobs = UnitAssemblyJob.active
        expect(active_jobs).to include(pending_job, materials_pending_job, in_progress_job)
        expect(active_jobs).not_to include(completed_job)
      end
    end
  end
end