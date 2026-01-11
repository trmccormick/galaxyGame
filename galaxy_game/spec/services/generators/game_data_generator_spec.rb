require 'rails_helper'

RSpec.describe Generators::GameDataGenerator do
  let(:generator) { described_class.new('llama3') }
  let(:template_path) { 'spec/fixtures/sample_template.json' }
  let(:output_path) { 'tmp/generated_item.json' }
  let(:params) { { name: 'Test Item', description: 'A test item.' } }

  before do
    FileUtils.mkdir_p('spec/fixtures')
    File.write(template_path, { metadata: { version: '1.0' }, name: '', description: '' }.to_json)
  end

  after do
    FileUtils.rm_rf('tmp')
    FileUtils.rm_f(template_path)
  end

  it 'generates and saves a valid JSON item' do
    allow_any_instance_of(Generators::GameDataGenerator).to receive(:generate_content).and_return({ name: 'Test Item', description: 'A test item.' }.to_json)
    result = generator.generate_item(template_path, output_path, params)
    expect(result['name']).to eq('Test Item')
    expect(File).to exist(output_path)
  end
end