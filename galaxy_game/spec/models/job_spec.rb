require 'rails_helper'

RSpec.describe Job, type: :model do
  let(:owner) { create(:player) }
  let(:settlement) { create(:settlement) }
  let(:blueprint) { create(:blueprint) }

  it "is valid with valid attributes" do
    job = described_class.new(
      owner: owner,
      settlement: settlement,
      job_type: :material_processing,
      status: :in_progress,
      output_type: "component",
      completes_at: 1.hour.from_now,
      blueprint: blueprint
    )
    expect(job).to be_valid
  end

  it "is invalid without a job_type" do
    job = build(:job, job_type: nil)
    expect(job).not_to be_valid
  end

  it "is invalid without a status" do
    job = build(:job, status: nil)
    expect(job).not_to be_valid
  end

  it "is invalid without an output_type" do
    job = build(:job, output_type: nil)
    expect(job).not_to be_valid
  end

  it "is invalid without a completes_at" do
    job = build(:job, completes_at: nil)
    expect(job).not_to be_valid
  end
end
