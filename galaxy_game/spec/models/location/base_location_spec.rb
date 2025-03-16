# spec/models/location/base_location_spec.rb
require 'rails_helper'

RSpec.describe Location::BaseLocation, type: :model do
  # Create concrete test class for validation testing
  let(:test_location_class) do
    Class.new(described_class) do
      self.table_name = 'base_locations'
    end
  end

  # Set up test subject
  subject(:test_location) do
    test_location_class.new(
      name: 'Test Location',
      coordinates: '0.00°N 0.00°E'
    )
  end

  before do
    stub_const('TestLocation', test_location_class)
  end

  # Test abstract class behavior
  it "is an abstract class" do
    expect(described_class.abstract_class).to be true
  end

  # Test associations using test class
  describe 'associations' do
    it { is_expected.to belong_to(:locationable).optional }
    it { is_expected.to have_many(:items) }
  end

  # Test validations using test class
  describe 'validations' do
    describe 'presence' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_presence_of(:coordinates) }
    end

    describe 'format' do
      it 'accepts valid coordinates' do
        location = test_location_class.new(
          name: 'Test',
          coordinates: '57.58°S 174.77°E'
        )
        expect(location).to be_valid
      end

      it 'rejects invalid coordinates' do
        location = test_location_class.new(
          name: 'Test',
          coordinates: 'invalid'
        )
        expect(location).not_to be_valid
      end
    end

    describe 'uniqueness' do
      subject { test_location_class.create!(name: 'Test', coordinates: '57.58°S 174.77°E') }
      
      it { is_expected.to validate_uniqueness_of(:coordinates) }
    end
  end

  # Test instance methods
  describe '#update_location' do
    let(:test_location) { 
      test_location_class.new(
        name: 'Test', 
        coordinates: '57.58°S 174.77°E'
      ) 
    }
    
    context 'with valid attributes' do
      let(:new_attributes) { { name: 'Updated Name' } }
      
      it 'updates the attributes' do
        allow(test_location).to receive(:update).with(new_attributes).and_return(true)
        expect(test_location.update_location(new_attributes)).to be true
      end
    end
  end
end
