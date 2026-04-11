# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Structures::WorldhouseSegment, type: :model do
  let(:worldhouse) { create(:worldhouse) }
  let(:segment) { create(:worldhouse_segment, worldhouse: worldhouse, length_m: 100.0, width_m: 50.0) }

  describe 'validations' do
    it 'requires segment_index' do
      expect(build(:worldhouse_segment, segment_index: nil)).not_to be_valid
    end
    it 'requires length_m to be greater than 0' do
      expect(build(:worldhouse_segment, length_m: 0)).not_to be_valid
      expect(build(:worldhouse_segment, length_m: -5)).not_to be_valid
    end
    it 'requires width_m to be greater than 0' do
      expect(build(:worldhouse_segment, width_m: 0)).not_to be_valid
      expect(build(:worldhouse_segment, width_m: -10)).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to worldhouse' do
      expect(segment.worldhouse).to eq(worldhouse)
    end
    it 'has many construction_jobs' do
      expect(segment.construction_jobs).to be_a_kind_of(ActiveRecord::Associations::CollectionProxy)
    end
  end

  describe 'defaults' do
    it 'defaults segment_type to residential' do
      expect(build(:worldhouse_segment).segment_type).to eq('residential')
    end
    it 'defaults status to planned' do
      expect(build(:worldhouse_segment).status).to eq('planned')
    end
  end

  describe 'area calculations' do
    it 'calculates area_m2 from length and width' do
      s = build(:worldhouse_segment, length_m: 20, width_m: 10)
      expect(s.area_m2).to eq(200)
    end
    it 'calculates area_km2 from area_m2' do
      s = build(:worldhouse_segment, length_m: 2000, width_m: 500)
      expect(s.area_km2).to eq(1.0)
    end
  end

  describe '#required_panel_count' do
    it 'calculates panel count from area' do
      s = build(:worldhouse_segment, length_m: 25, width_m: 25)
      expect(s.required_panel_count).to eq(25)
    end
    it 'rounds up to nearest whole panel' do
      s = build(:worldhouse_segment, length_m: 26, width_m: 25)
      expect(s.required_panel_count).to eq(26)
    end
  end

  describe '#required_materials' do
    it 'returns a hash with required material keys' do
      expect(segment.required_materials.keys).to include('modular_structural_panel', 'structural_support_beam', 'pressure_seal', 'mounting_hardware')
    end
    it 'includes modular_structural_panel' do
      expect(segment.required_materials).to have_key('modular_structural_panel')
    end
    it 'includes structural_support_beam' do
      expect(segment.required_materials).to have_key('structural_support_beam')
    end
    it 'includes pressure_seal' do
      expect(segment.required_materials).to have_key('pressure_seal')
    end
    it 'includes mounting_hardware' do
      expect(segment.required_materials).to have_key('mounting_hardware')
    end
  end

  describe '#begin_construction!' do
    it 'returns false unless planned' do
      s = build(:worldhouse_segment, status: 'under_construction', length_m: 10, width_m: 10)
      expect(s.begin_construction!).to be false
    end
    it 'updates status to materials_requested when planned' do
      s = create(:worldhouse_segment, status: 'planned', length_m: 10, width_m: 10)
      allow(MaterialRequest).to receive(:create!).and_return(double)
      expect(s.begin_construction!).to be_truthy
      expect(s.status).to eq('materials_requested')
    end
  end

  describe '#complete!' do
    it 'returns false unless under_construction' do
      s = build(:worldhouse_segment, status: 'planned', length_m: 10, width_m: 10)
      expect(s.complete!).to be false
    end
    it 'updates status to enclosed when under_construction' do
      s = create(:worldhouse_segment, status: 'under_construction', worldhouse: worldhouse, length_m: 10, width_m: 10)
      allow(worldhouse).to receive(:recalculate_progress!)
      s.complete!
      expect(s.status).to eq('enclosed')
    end
  end
end
