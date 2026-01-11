# spec/services/pressurization_service_spec.rb
require 'rails_helper'

RSpec.describe PressurizationService do
  let(:settlement) { create(:base_settlement) }
  let(:atmosphere) { create(:atmosphere, pressure: 0.0, total_atmospheric_mass: 0.0) }

  describe '#check_sealing_status' do
    context 'with traditional sealed environment' do
      let(:sealed_environment) do
        double('sealed_environment',
          is_sealed: true,
          atmospheric_data: atmosphere
        )
      end

      let(:unsealed_environment) do
        double('unsealed_environment',
          is_sealed: false,
          atmospheric_data: atmosphere
        )
      end

      it 'returns ready for sealed environment' do
        service = described_class.new(sealed_environment)
        result = service.check_sealing_status
        expect(result[:ready]).to be_truthy
      end

      it 'returns not ready for unsealed environment' do
        service = described_class.new(unsealed_environment)
        result = service.check_sealing_status
        expect(result[:ready]).to be_falsey
        expect(result[:message]).to include('not sealed')
      end
    end

    context 'with pressurization target (lava tube)' do
      let(:lava_tube) do
        create(:lava_tube,
          operational_data: {
            'pressurization_requirements' => { 'plugs' => 2, 'domes' => 1 },
            'pressurization_progress' => {
              'seals' => { 'plugs' => 1, 'domes' => 0 }
            }
          }
        )
      end

      let(:ready_lava_tube) do
        create(:lava_tube,
          operational_data: {
            'pressurization_requirements' => { 'plugs' => 2, 'domes' => 1 },
            'pressurization_progress' => {
              'seals' => { 'plugs' => 2, 'domes' => 1 },
              'ready_for_pressurization' => true
            }
          }
        )
      end

      it 'returns not ready when requirements not met' do
        service = described_class.new(lava_tube)
        result = service.check_sealing_status
        expect(result[:ready]).to be_falsey
        expect(result[:message]).to include('requires')
      end

      it 'returns ready when requirements met' do
        service = described_class.new(ready_lava_tube)
        result = service.check_sealing_status
        expect(result[:ready]).to be_truthy
      end
    end

    context 'with pressurization target (canyon)' do
      let(:canyon) do
        create(:canyon_feature,
          operational_data: {
            'pressurization_requirements' => { 'plugs' => 1, 'domes' => 2 },
            'pressurization_progress' => {
              'seals' => { 'plugs' => 0, 'domes' => 1 }
            }
          }
        )
      end

      it 'returns not ready when requirements not met' do
        service = described_class.new(canyon)
        result = service.check_sealing_status
        expect(result[:ready]).to be_falsey
        expect(result[:message]).to include('requires')
      end
    end
  end
end