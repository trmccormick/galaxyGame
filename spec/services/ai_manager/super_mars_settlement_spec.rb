require 'rails_helper'

RSpec.describe AIManager::SuperMarsSettlementService, type: :service do
  let(:service) { described_class.new }

  describe '#choose_pattern' do
    context 'MoonlessPlanetPattern' do
      let(:planet) do
        {
          name: 'SuperMars',
          moons: [],
          nearby_asteroids: [
            { name: 'Ast1', size: :phobos },
            { name: 'Ast2', size: :deimos }
          ],
          tug_craft: [{ id: 1 }, { id: 2 }],
          surface_accessible: true
        }
      end
      it 'redirects asteroids as moons' do
        result = service.choose_pattern(planet)
        expect(result.size).to eq(2)
        expect(result.all? { |r| [:phobos, :deimos].include?(r[:asteroid][:size]) }).to be true
      end
    end

    context 'LargeMoonPattern' do
      let(:planet) do
        {
          name: 'SuperMars',
          moons: [ { name: 'LunaTwin', size: :luna } ],
          surface_accessible: true
        }
      end
      it 'settles the moon and builds L1 depot' do
        result = service.choose_pattern(planet)
        expect(result[:moon]).to eq('LunaTwin')
        expect(result[:depot]).to eq(:l1)
      end
    end

    context 'Surface Accessibility Gate' do
      let(:planet) do
        {
          name: 'SuperMars',
          moons: [ { name: 'TinyMoon', size: :tiny } ],
          surface_accessible: false
        }
      end
      it 'imports station components if surface not accessible' do
        service.choose_pattern(planet)
        expect(planet[:imported_station_components]).to eq(true)
      end
    end
  end

  describe '#configure_panels' do
    let(:depot) { {} }
    it 'sets panel configuration' do
      service.configure_panels(depot, :solar)
      expect(depot[:panels]).to eq(:solar)
    end
  end
end
