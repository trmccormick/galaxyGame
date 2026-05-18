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

    # context 'construction jobs' do
    #   it 'processes ConstructionJob the same as Job' do
    #     job = create(:construction_job, status: :in_progress, completes_at: 1.hour.ago)
    #     described_class.new.perform
    #     expect(job.reload.status).to eq('ready_to_claim')
    #   end
    # end

    context 'error handling' do
      it 'continues after job failure' do
        failing_job = create(:job, status: :in_progress, completes_at: 1.hour.ago)
        passing_job = create(:job, status: :in_progress, completes_at: 1.hour.ago)
        allow_any_instance_of(Job).to receive(:update!).and_wrap_original do |method, *args|
          raise StandardError, 'boom' if method.receiver.id == failing_job.id
          method.call(*args)
        end
        described_class.new.perform
        expect(passing_job.reload.status).to eq('ready_to_claim')
      end
    end

    it 'handles no jobs gracefully' do
      expect { described_class.new.perform }.not_to raise_error
    end

    context 'pending job promotion' do
      let(:settlement) { create(:base_settlement) }
      let(:unit) do
        create(:base_unit, settlement: settlement, operational_data: {
          'job_types' => {
            'supported' => ['material_processing'],
            'max_concurrent' => 2
          }
        })
      end

      it 'promotes oldest pending jobs up to available capacity' do
        jobs = [
          create(:job, settlement: settlement, job_type: :material_processing, status: :pending, created_at: 2.hours.ago),
          create(:job, settlement: settlement, job_type: :material_processing, status: :pending, created_at: 1.hour.ago)
        ]
        unit # ensure unit is created
        described_class.new.perform
        jobs.each { |job| expect(job.reload.status).to eq('in_progress') }
      end

      it 'does not promote more jobs than available capacity' do
        unit # capacity 2
        create(:job, settlement: settlement, job_type: :material_processing, status: :in_progress)
        jobs = [
          create(:job, settlement: settlement, job_type: :material_processing, status: :pending, created_at: 2.hours.ago),
          create(:job, settlement: settlement, job_type: :material_processing, status: :pending, created_at: 1.hour.ago)
        ]
        described_class.new.perform
        expect(jobs[0].reload.status).to eq('in_progress')
        expect(jobs[1].reload.status).to eq('pending')
      end

      it 'sets start_date and completes_at on promotion' do
        unit # capacity 2
        job = create(:job, settlement: settlement, job_type: :material_processing, status: :pending, operational_data: { 'production_time_hours' => 3 })
        described_class.new.perform
        job.reload
        expect(job.status).to eq('in_progress')
        expect(job.start_date).to be_within(1.second).of(Time.current)
        expect(job.completes_at).to be_within(1.second).of(Time.current + 3.hours)
      end

      it 'uses a fallback production time if missing or invalid' do
        unit # capacity 2
        job = create(:job, settlement: settlement, job_type: :material_processing, status: :pending, operational_data: {})
        described_class.new.perform
        job.reload
        expect(job.completes_at).to be_within(1.second).of(Time.current + 1.hour)
      end

      it 'does not promote jobs if no capacity' do
        unit # capacity 2
        2.times { create(:job, settlement: settlement, job_type: :material_processing, status: :in_progress) }
        job = create(:job, settlement: settlement, job_type: :material_processing, status: :pending)
        described_class.new.perform
        expect(job.reload.status).to eq('pending')
      end
    end
  end
end