require 'rails_helper'

RSpec.describe Construction::ConstructionManager, type: :service do
  let(:entity) { double('Entity', estimated_completion: 1.hour.ago) }
  let(:future_entity) { double('Entity', estimated_completion: 1.hour.from_now) }

  describe '.assign_builders' do
    it 'logs and returns true' do
      expect(Rails.logger).to receive(:info).with(/Assigning builders to/)
      expect(described_class.assign_builders(entity, 10)).to eq(true)
    end
  end

  describe '.complete?' do
    it 'returns true if current time >= estimated_completion' do
      expect(described_class.complete?(entity)).to be true
    end

    it 'returns false if current time < estimated_completion' do
      expect(described_class.complete?(future_entity)).to be false
    end

    it 'returns false if entity does not respond to estimated_completion' do
      no_time_entity = double('Entity')
      expect(described_class.complete?(no_time_entity)).to be false
    end

    it 'returns false if estimated_completion is nil' do
      nil_time_entity = double('Entity', estimated_completion: nil)
      expect(described_class.complete?(nil_time_entity)).to be false
    end
  end
end
