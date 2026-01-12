# spec/data/template_integrity_spec.rb
require 'rails_helper'
require 'json'

RSpec.describe 'Alien World Template Integrity' do
  let(:template_path) do
    Rails.root.join(
      'app',
      'data',
      'templates',
      'alien_world_templates_v1.1.json'
    )
  end

  let(:raw_json) { File.read(template_path) }
  let(:data) { JSON.parse(raw_json) }
  let(:templates) { data['terrestrial_planets'] }

  it 'template file exists' do
    expect(File.exist?(template_path)).to be(true),
      "Expected alien_world_templates_v1.1.json at #{template_path}"
  end

  it 'is valid JSON' do
    expect { JSON.parse(raw_json) }.not_to raise_error
  end

  it 'contains terrestrial_planets array' do
    expect(templates).to be_an(Array)
  end

  it 'contains exactly 25 templates (A01 → A25)' do
    skip 'Templates not generated yet' if templates.empty?
    identifiers = templates.map { |t| t['identifier'] }
    expected = (1..25).map { |i| format('TPL-A%02d', i) }

    expect(identifiers.sort).to eq(expected)
  end

  it 'has unique identifiers' do
    skip 'Templates not generated yet' if templates.empty?
    identifiers = templates.map { |t| t['identifier'] }
    expect(identifiers.uniq.length).to eq(identifiers.length)
  end

  it 'has unique template names' do
    skip 'Templates not generated yet' if templates.empty?
    names = templates.map { |t| t['name'] }
    expect(names.uniq.length).to eq(names.length)
  end

  describe 'required schema fields' do
    let(:required_keys) do
      %w[
        type name identifier mass radius density size
        surface_temperature gravity albedo known_pressure
        geological_activity atmosphere geosphere_attributes
        terraforming_difficulty volatile_reservoir
        engineered_atmosphere material_yield_bias
      ]
    end

    it 'each template contains all required fields' do
      skip 'Templates not generated yet' if templates.empty?
      templates.each do |template|
        missing = required_keys - template.keys
        expect(missing).to be_empty,
          "Template #{template['identifier']} missing: #{missing.join(', ')}"
      end
    end
  end

  describe 'atmosphere rules' do
    it 'contains no oxygen by default' do
      skip 'Templates not generated yet' if templates.empty?
      templates.each do |template|
        composition = template.dig('atmosphere', 'composition') || {}
        expect(composition).not_to have_key('O2'),
          "Template #{template['identifier']} incorrectly contains O2"
      end
    end

    it 'has pressure > 0' do
      skip 'Templates not generated yet' if templates.empty?
      templates.each do |template|
        pressure = template.dig('atmosphere', 'pressure')
        expect(pressure).to be > 0
      end
    end
  end

  describe 'terraforming metadata' do
    it 'terraforming_difficulty is between 1 and 10' do
      skip 'Templates not generated yet' if templates.empty?
      templates.each do |template|
        difficulty = template['terraforming_difficulty']
        expect(difficulty).to be_between(1.0, 10.0)
      end
    end

    it 'engineered_atmosphere defaults to false' do
      skip 'Templates not generated yet' if templates.empty?
      templates.each do |template|
        expect(template['engineered_atmosphere']).to eq(false)
      end
    end
  end

  describe 'volatile reservoirs' do
    it 'has CO2 and H2O reservoirs defined' do
      skip 'Templates not generated yet' if templates.empty?
      templates.each do |template|
        reservoir = template['volatile_reservoir']
        expect(reservoir).to include('total_CO2_available', 'total_H2O_available')
      end
    end
  end

  describe 'material yield bias' do
    it 'contains all yield bias categories' do
      skip 'Templates not generated yet' if templates.empty?
      templates.each do |template|
        bias = template['material_yield_bias']
        expect(bias.keys).to contain_exactly(
          'rare_earth_elements',
          'precious_metals',
          'industrial_metals'
        )
      end
    end
  end
end