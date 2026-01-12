require 'rails_helper'

RSpec.describe CelestialBodies::Material, type: :model do
  let(:celestial_body) { create(:celestial_body) }
  let(:material) { create(:material, celestial_body: celestial_body) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(material).to be_valid
    end

    it 'is not valid without a name' do
      material.name = nil
      expect(material).to_not be_valid
    end

    it 'is not valid without an amount' do
      material.amount = nil
      expect(material).to_not be_valid
    end

    it 'is not valid with a negative amount' do
      material.amount = -1
      expect(material).to_not be_valid
    end

    it 'is not valid without a state' do
      material.state = nil
      expect(material).to_not be_valid
    end

    it 'is valid with a valid state (solid, liquid, gas)' do
      %w[solid liquid gas].each do |valid_state|
        material.state = valid_state
        expect(material).to be_valid
      end
    end

    it 'is not valid with an invalid state' do
      material.state = 'unknown_state'
      expect(material).to_not be_valid
    end

    it 'is valid with valid melting and boiling points' do
      material.melting_point = 273  # Example melting point (in Kelvin)
      material.boiling_point = 373   # Example boiling point (in Kelvin)
      expect(material).to be_valid
    end

    it 'is not valid with non-numeric melting and boiling points' do
      material.melting_point = 'invalid'
      material.boiling_point = 'invalid'
      expect(material).to_not be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a celestial body' do
      expect(material.celestial_body).to eq(celestial_body)
    end
  end

  describe '#state_at' do
    it 'returns "solid" when temperature is below the adjusted melting point' do
      expect(material.state_at(250, 1.0)).to eq('solid')
    end

    it 'returns "liquid" when temperature is between the adjusted melting and boiling points' do
      expect(material.state_at(400, 1.0)).to eq('liquid')
    end

    it 'returns "gas" when temperature is above the adjusted boiling point' do
      expect(material.state_at(600, 1.0)).to eq('gas')
    end
  end

  # describe '#add_to_atmosphere' do
    # let(:atmosphere) { Atmosphere.new(celestial_body: celestial_body) }

    # context 'when material is in gas state' do
    #   before do
    #     material.update(name: 'Nitrogen', amount: 100, melting_point: 63, boiling_point: 77, vapor_pressure: 0.5)
    #     celestial_body.add_material('Nitrogen', 100)
    #   end

    #   it 'adds the material to the atmosphere' do
    #     expect { material.add_to_atmosphere(atmosphere) }.to change { atmosphere.gases.count }.by(1)
    #     expect(celestial_body.materials).to include(material)
    #   end
    # end

    # context 'when material is not in gas state' do
    #   before do
    #     material.update(state: 'solid')
    #   end

    #   it 'does not add the material to the atmosphere' do
    #     material.add_to_atmosphere(atmosphere)
    #     expect(atmosphere.gases).to_not include(material)
    #   end
    # end
  # end
end
