# spec/models/component_production_job_spec.rb
require 'rails_helper'

RSpec.describe ComponentProductionJob, type: :model do
  let(:settlement) { create(:base_settlement) }
  let(:printer_unit) { create(:base_unit, owner: settlement) }
  
  let(:job) do
    create(:component_production_job,
      settlement: settlement,
      printer_unit: printer_unit,
      component_blueprint_id: '3d_printed_ibeam',
      component_name: '3D-Printed I-Beam',
      quantity: 5,
      production_time_hours: 10.0,
      status: 'pending'
    )
  end

  describe 'associations' do
    it { is_expected.to belong_to(:settlement) }
    it { is_expected.to belong_to(:printer_unit) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:component_blueprint_id) }
    it { is_expected.to validate_presence_of(:component_name) }
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0).only_integer }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:production_time_hours) }
    it { is_expected.to validate_numericality_of(:production_time_hours).is_greater_than(0) }
  end

  describe 'scopes' do
    let!(:pending_job) { create(:component_production_job, status: 'pending') }
    let!(:in_progress_job) { create(:component_production_job, status: 'in_progress') }
    let!(:completed_job) { create(:component_production_job, status: 'completed') }

    it 'returns active jobs' do
      expect(ComponentProductionJob.active).to contain_exactly(pending_job, in_progress_job)
    end

    it 'returns completed jobs' do
      expect(ComponentProductionJob.completed).to contain_exactly(completed_job)
    end

    it 'returns in_progress jobs' do
      expect(ComponentProductionJob.in_progress).to contain_exactly(in_progress_job)
    end
  end

  describe '#start!' do
    it 'changes status to in_progress and sets started_at' do
      expect { job.start! }.to change { job.status }.from('pending').to('in_progress')
      expect(job.started_at).to be_present
    end
  end

  describe '#complete!' do
    before { job.start! }

    it 'changes status to completed and sets completed_at' do
      expect { job.complete! }.to change { job.status }.from('in_progress').to('completed')
      expect(job.completed_at).to be_present
      expect(job.progress_hours).to eq(job.production_time_hours)
    end
  end

  describe '#fail!' do
    before { job.start! }

    it 'changes status to failed with reason' do
      expect { job.fail!('Printer malfunction') }
        .to change { job.status }.from('in_progress').to('failed')
      
      expect(job.completed_at).to be_present
      expect(job.metadata['failure_reason']).to eq('Printer malfunction')
    end
  end

  describe '#cancel!' do
    it 'changes status to cancelled' do
      expect { job.cancel! }.to change { job.status }.from('pending').to('cancelled')
      expect(job.completed_at).to be_present
    end
  end

  describe '#progress_percentage' do
    before { job.update!(progress_hours: 5.0) }

    it 'calculates progress percentage' do
      expect(job.progress_percentage).to eq(50.0)
    end
  end

  describe '#time_remaining_hours' do
    before { job.update!(progress_hours: 3.0) }

    it 'calculates remaining time' do
      expect(job.time_remaining_hours).to eq(7.0)
    end

    it 'returns 0 when complete' do
      job.update!(progress_hours: 15.0)
      expect(job.time_remaining_hours).to eq(0)
    end
  end

  describe '#estimated_completion' do
    it 'returns nil for pending jobs' do
      expect(job.estimated_completion).to be_nil
    end

    it 'calculates estimated completion time' do
      job.start!
      expected_time = job.started_at + 10.hours
      expect(job.estimated_completion).to be_within(1.second).of(expected_time)
    end
  end

  describe '#process_tick' do
    before { job.start! }

    context 'when job is not complete' do
      it 'increases progress_hours' do
        expect { job.process_tick(2.0) }
          .to change { job.progress_hours }.by(2.0)
        
        expect(job.status).to eq('in_progress')
      end
    end

    context 'when job completes during tick' do
      before { job.update!(progress_hours: 9.0) }

      it 'completes the job' do
        expect { job.process_tick(2.0) }
          .to change { job.status }.from('in_progress').to('completed')
        
        expect(job.completed_at).to be_present
      end
    end

    context 'when job is not in_progress' do
      before { job.update!(status: 'pending') }

      it 'does not process tick' do
        expect { job.process_tick(2.0) }
          .not_to change { job.progress_hours }
      end
    end
  end

  describe '#active?' do
    it 'returns true for pending jobs' do
      job.update!(status: 'pending')
      expect(job).to be_active
    end

    it 'returns true for in_progress jobs' do
      job.update!(status: 'in_progress')
      expect(job).to be_active
    end

    it 'returns false for completed jobs' do
      job.update!(status: 'completed')
      expect(job).not_to be_active
    end
  end

  describe '#finished?' do
    it 'returns true for completed jobs' do
      job.update!(status: 'completed')
      expect(job).to be_finished
    end

    it 'returns true for failed jobs' do
      job.update!(status: 'failed')
      expect(job).to be_finished
    end

    it 'returns false for in_progress jobs' do
      job.update!(status: 'in_progress')
      expect(job).not_to be_finished
    end
  end
end