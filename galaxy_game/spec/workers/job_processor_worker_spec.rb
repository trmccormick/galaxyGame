require 'rails_helper'

RSpec.describe JobProcessorWorker, type: :worker do
  describe '#perform' do
    context 'completes overdue jobs' do
      it 'sets status to ready_to_claim when completes_at is past' do
        job = create(:job, status: :in_progress, completes_at: 1.hour.ago)
        described_class.new.perform
        expect(job.reload.status).to eq('ready_to_claim')
      end

      it 'leaves future completes_at jobs in_progress' do
        job = create(:job, status: :in_progress, completes_at: 1.hour.from_now)
        described_class.new.perform
        expect(job.reload.status).to eq('in_progress')
      end
    end

    context 'construction jobs' do
      it 'processes ConstructionJob the same as Job' do
        job = create(:construction_job, status: :in_progress, completes_at: 1.hour.ago)
        described_class.new.perform
        expect(job.reload.status).to eq('ready_to_claim')
      end
    end

    context 'error handling' do
      it 'continues after job failure' do
        failing_job = create(:job, status: :in_progress, completes_at: 1.hour.ago)
        passing_job = create(:job, status: :in_progress, completes_at: 1.hour.ago)
        allow_any_instance_of(Job).to receive(:update!).and_raise(StandardError, 'boom')
        described_class.new.perform
        expect(passing_job.reload.status).to eq('ready_to_claim')
      end
    end

    it 'handles no jobs gracefully' do
      expect { described_class.new.perform }.not_to raise_error
    end
  end
end