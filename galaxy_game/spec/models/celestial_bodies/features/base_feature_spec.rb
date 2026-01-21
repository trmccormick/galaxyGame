# spec/models/celestial_bodies/features/base_feature_spec.rb
require 'rails_helper'

RSpec.describe CelestialBodies::Features::BaseFeature, type: :model do
  let(:star) { create(:star) }
  let(:sol) { create(:solar_system, current_star: star, name: 'Sol') }
  let(:luna) { create(:moon, name: 'Luna', identifier: 'luna', solar_system: sol) }
  
  describe 'associations' do
    it { should belong_to(:celestial_body) }
    it { should belong_to(:parent_feature).optional }
    it { should have_many(:child_features) }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:feature_id) }
    it { should validate_presence_of(:feature_type) }
    it { should validate_presence_of(:status) }
  end
  
  describe '#static_data' do
    let(:static_data) do
      {
        'name' => 'Marius Hills Skylight',
        'coordinates' => { 'lat' => 10.0, 'lon' => 20.0 },
        'tier' => 'strategic',
        'discovered' => false
      }
    end
    let(:feature) { create(:lava_tube_feature, celestial_body: luna, feature_id: 'luna_lt_001', static_data: nil) }

    before do
      allow(Lookup::PlanetaryGeologicalFeatureLookupService).to receive(:new).with(luna).and_return(
        double(find_by_id: static_data)
      )
    end

    it 'fetches data from lookup service' do
      expect(feature.static_data).to be_a(Hash)
      expect(feature.static_data['name']).to eq('Marius Hills Skylight')
    end

    it 'caches the data' do
      feature.static_data
      expect(Lookup::PlanetaryGeologicalFeatureLookupService).not_to receive(:new)
      feature.static_data
    end
  end
  
  describe '#discover!' do
    let(:feature) { create(:lava_tube_feature, celestial_body: luna, feature_id: 'luna_lt_001') }
    before do
      allow(Lookup::PlanetaryGeologicalFeatureLookupService).to receive(:new).and_return(
        double(find_by_id: { 'name' => 'Marius Hills Skylight', 'tier' => 'strategic', 'discovered' => false })
      )
    end

    it 'marks feature as discovered' do
      expect {
        feature.discover!(123)
      }.to change { feature.discovered_by }.from(nil).to(123)
       .and change { feature.status }.from('natural').to('surveyed')
    end

    it 'sets discovered_at timestamp' do
      feature.discover!(123)
      expect(feature.discovered_at).to be_within(1.second).of(Time.current)
    end

    it 'does not overwrite existing discovery' do
      feature.discover!(123)
      original_time = feature.discovered_at

      feature.discover!(456)
      feature.reload

      expect(feature.discovered_by).to eq(123)
      expect(feature.discovered_at).to eq(original_time)
    end
  end
  
  describe 'status transitions' do
    let(:feature) { create(:lava_tube_feature, celestial_body: luna, feature_id: 'luna_lt_001') }
    before do
      allow(Lookup::PlanetaryGeologicalFeatureLookupService).to receive(:new).and_return(
        double(find_by_id: { 'name' => 'Marius Hills Skylight', 'tier' => 'strategic', 'discovered' => false })
      )
    end

    it 'transitions through states correctly' do
      expect(feature.natural?).to be true

      feature.survey!
      expect(feature.surveyed?).to be true

      feature.enclose!
      expect(feature.enclosed?).to be true

      feature.pressurize!
      expect(feature.pressurized?).to be true

      feature.establish_settlement!(999)
      expect(feature.has_settlement?).to be true
      expect(feature.settlement_id).to eq(999)
    end

    it 'cannot skip states' do
      expect(feature.enclose!).to be false
      expect(feature.natural?).to be true
    end
  end
  
  describe 'tier helpers' do
    it 'identifies strategic features' do
      lookup_double = double()
      allow(lookup_double).to receive(:find_by_id).with('luna_lt_001').and_return({ 'tier' => 'strategic' })
      allow(lookup_double).to receive(:find_by_id).and_return({})
      allow(Lookup::PlanetaryGeologicalFeatureLookupService).to receive(:new).and_return(lookup_double)
      feature = build(:lava_tube_feature, celestial_body: luna, feature_id: 'luna_lt_001', feature_type: 'lava_tube')
      allow(feature).to receive(:static_data).and_return({ 'tier' => 'strategic' })
      expect(feature.strategic?).to be true
      expect(feature.catalog?).to be false
    end

    it 'identifies catalog features' do
      lookup_double = double()
      allow(lookup_double).to receive(:find_by_id).with('luna_cr_cat_0001').and_return({ 'tier' => 'catalog' })
      allow(lookup_double).to receive(:find_by_id).and_return({})
      allow(Lookup::PlanetaryGeologicalFeatureLookupService).to receive(:new).and_return(lookup_double)
      feature = build(:crater_feature, :catalog, celestial_body: luna, feature_id: 'luna_cr_cat_0001', feature_type: 'crater')
      allow(feature).to receive(:static_data).and_return({ 'tier' => 'catalog' })
      expect(feature.catalog?).to be true
      expect(feature.strategic?).to be false
    end
  end
end