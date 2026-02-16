# spec/services/ai_manager/testing/sandbox_environment_spec.rb
require 'rails_helper'

RSpec.describe AIManager::Testing::SandboxEnvironment, type: :service do
  let(:sandbox) { described_class.new }

  describe '#activate_sandbox' do
    it 'activates sandbox environment' do
      sandbox.activate_sandbox

      expect(sandbox.sandbox_active?).to be true
    end

    it 'isolates AI services' do
      sandbox.activate_sandbox

      expect(sandbox.isolated_services).to include('task_execution_engine')
      expect(sandbox.isolated_services).to include('resource_acquisition_service')
    end
  end

  describe '#deactivate_sandbox' do
    before do
      sandbox.activate_sandbox
    end

    it 'deactivates sandbox environment' do
      sandbox.deactivate_sandbox

      expect(sandbox.sandbox_active?).to be false
    end

    it 'clears isolated services' do
      sandbox.deactivate_sandbox

      expect(sandbox.isolated_services).to be_empty
    end
  end

  describe '#within_sandbox' do
    it 'executes code within sandbox context' do
      result = nil

      sandbox.within_sandbox do
        result = sandbox.sandbox_active?
      end

      expect(result).to be true
    end

    it 'deactivates sandbox after execution' do
      sandbox.within_sandbox do
        # Do nothing
      end

      expect(sandbox.sandbox_active?).to be false
    end

    it 'handles exceptions properly' do
      expect do
        sandbox.within_sandbox do
          raise 'Test error'
        end
      end.to raise_error('Test error')

      # Sandbox should still be deactivated
      expect(sandbox.sandbox_active?).to be false
    end
  end

  describe '#isolate_service' do
    before do
      sandbox.activate_sandbox
    end

    it 'isolates a service' do
      test_service = Class.new
      sandbox.isolate_service(test_service)

      expect(sandbox.isolated_services).to include('class')
    end
  end

  describe '#add_mock_data and #get_mock_data' do
    before do
      sandbox.activate_sandbox
    end

    it 'adds and retrieves mock data' do
      sandbox.add_mock_data(:test_key, { value: 42 })

      data = sandbox.get_mock_data(:test_key)
      expect(data[:value]).to eq(42)
    end
  end

  describe '#override_service_method' do
    before do
      sandbox.activate_sandbox
    end

    it 'overrides service method' do
      test_service = Class.new do
        def self.test_method
          'original'
        end
      end

      sandbox.override_service_method(test_service, :test_method, lambda { 'overridden' })

      expect(test_service.test_method).to eq('overridden')
    end
  end

  describe '#sandbox_status' do
    before do
      sandbox.activate_sandbox
    end

    it 'returns sandbox status' do
      status = sandbox.sandbox_status

      expect(status[:active]).to be true
      expect(status).to have_key(:isolated_services_count)
      expect(status).to have_key(:mock_data_keys)
    end
  end
end