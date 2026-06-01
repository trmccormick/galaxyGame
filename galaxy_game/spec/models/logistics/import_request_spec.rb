require 'rails_helper'

describe Logistics::ImportRequest, type: :model do

  it 'has valid factory' do
    req = FactoryBot.create(:import_request)
    expect(req).to be_valid
    expect(req.status).to eq('created')
    expect(req.tier).to eq('survival')
    expect(req.priority).to eq('normal')
    expect(req.category).to eq('other')
  end

  it 'requires settlement, resource, quantity_needed, status, tier, priority, and category' do
    req = Logistics::ImportRequest.new(status: nil, tier: nil, priority: nil, category: nil)
    expect(req).not_to be_valid
    expect(req.errors[:settlement]).to be_present
    expect(req.errors[:resource]).to be_present
    expect(req.errors[:quantity_needed]).to be_present
    expect(req.errors[:status]).to be_present
    expect(req.errors[:tier]).to be_present
    expect(req.errors[:priority]).to be_present
    expect(req.errors[:category]).to be_present
  end

  it 'serializes cost_analysis as JSON' do
    req = FactoryBot.create(:import_request, cost_analysis: { foo: 'bar' })
    expect(req.cost_analysis).to eq({ 'foo' => 'bar' })
  end

  it 'belongs to a manifest (optional)' do
    req = FactoryBot.create(:import_request)
    expect(req.manifest).to be_nil.or be_a(Logistics::Manifest)
  end
end
