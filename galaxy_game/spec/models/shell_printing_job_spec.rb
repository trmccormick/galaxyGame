# spec/models/shell_printing_job_spec.rb
require 'rails_helper'

RSpec.describe ShellPrintingJob, type: :model do
  let(:settlement) { create(:base_settlement) }
  let(:printer_unit) { create(:base_unit, owner: settlement) }
  let(:inflatable_tank) { create(:base_unit, owner: settlement) }
  
  let(:job) do
    create(:shell_printing_job,
      settlement: settlement,
      printer_unit: printer_unit,
      inflatable_tank: inflatable_tank,
      production_time_hours: 10.0,
      status: 'pending'
    )
  end

  describe 'associations' do
    it { is_expected.to belong_to(:settlement) }
    it { is_expected.to belong_to(:printer_unit) }
    it { is_expected.to belong_to(:inflatable_tank) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:production_time_hours) }
    it { is_expected.to validate_numericality_of(:production_time_hours).is_greater_than(0) }
  end

  describe 'scopes' do
    let!(:pending_job) { create(:shell_printing_job, status: 'pending') }
    let!(:in_progress_job) { create(:shell_printing_job, status: 'in_progress') }
    let!(:completed_job) { create(:shell_printing_job, status: 'completed') }

    it 'returns active jobs' do
      expect(ShellPrintingJob.active).to contain_exactly(pending_job, in_progress_job)
    end

    it 'returns completed jobs' do
      expect(ShellPrintingJob.completed).to contain_exactly(completed_job)
    end

    it 'returns in_progress jobs' do
      expect(ShellPrintingJob.in_progress).to contain_exactly(in_progress_job)
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
  end
end