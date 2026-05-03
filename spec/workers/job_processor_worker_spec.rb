require 'rails_helper'

RSpec.describe JobProcessorWorker, type: :worker do
  let(:now) { Time.current }

  before { Timecop.freeze(now) }
  after { Timecop.return }

  describe '#perform' do
    it 'sets status to ready_to_claim for completed Job records' do
      job = create(:job, status: :in_progress, completes_at: now - 1.minute)
      expect {
        described_class.new.perform
        job.reload
      }.to change { job.status }.from('in_progress').to('ready_to_claim')
    end

    it 'does not change status if completes_at is in the future' do
      job = create(:job, status: :in_progress, completes_at: now + 1.hour)
      expect {
        described_class.new.perform
        job.reload
      }.not_to change { job.status }
    end

    it 'sets status to ready_to_claim for completed ConstructionJob records' do
      construction_job = ConstructionJob.create!(
        jobable: create(:settlement),
        settlement: create(:settlement),
        job_type: :crater_dome_construction,
        status: :in_progress,
        completes_at: now - 1.minute
      )
      expect {
        described_class.new.perform
        construction_job.reload
      }.to change { construction_job.status }.from('in_progress').to('ready_to_claim')
    end
  end
end
