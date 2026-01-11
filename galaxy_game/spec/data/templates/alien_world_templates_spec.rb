require 'rails_helper'
require 'json'

RSpec.describe 'Alien World Templates Integrity' do
  let(:template_path) do
    Rails.root.join(
      'data', 'json-data', 'templates', 'alien_world_templates_v1.1.json'
    )
  end

  let(:json) do
    JSON.parse(File.read(template_path))
  end

  it 'exists and is valid JSON' do
    expect(File.exist?(template_path)).to be true
    expect { json }.not_to raise_error
  end

  describe 'metadata' do
    let(:metadata) { json['metadata'] }

    it 'exists' do
      expect(metadata).to be_present
    end

    it 'has required fields' do
      %w[
        name
        version
        status
        schema
        compatible_generator
        created_at
        notes
      ].each do |field|
        expect(metadata).to have_key(field)
      end
    end

    it 'is versioned correctly' do
      expect(metadata['version']).to eq('1.1')
      expect(metadata['status']).to eq('stable')
    end
  end

  describe 'terrestrial planet templates' do
    let(:templates) { json['terrestrial_planets'] }

    it 'exists and is an array' do
      expect(templates).to be_an(Array)
    end

    it 'contains exactly 25 templates' do
      expect(templates.size).to eq(25)
    end

    it 'has unique identifiers' do
      ids = templates.map { |t| t['identifier'] }
      expect(ids.uniq.size).to eq(ids.size)
    end

    it 'covers Template-A01 through Template-A25' do
      expected = (1..25).map { |i| "TPL-A%02d" % i }
      actual   = templates.map { |t| t['identifier'] }.sort
      expect(actual).to eq(expected)
    end

    it 'all templates are terrestrial' do
      templates.each do |t|
        expect(t['type']).to eq('terrestrial')
      end
    end
  end

  describe 'template schema validation' do
    let(:required_fields) do
      %w[
        type name identifier mass radius density size
        orbital_period surface_temperature gravity
        albedo insolation known_pressure geological_activity
        atmosphere geosphere_attributes
        engineered_atmosphere terraforming_difficulty
        volatile_reservoir material_yield_bias
      ]
    end

    it 'each template contains all required fields' do
      json['terrestrial_planets'].each do |template|
        required_fields.each do |field|
          expect(template).to have_key(field),
            "Missing field #{field} in #{template['identifier']}"
        end
      end
    end
  end

  describe 'atmospheric constraints' do
    it 'contains no oxygen by default' do
      json['terrestrial_planets'].each do |template|
        composition = template.dig('atmosphere', 'composition') || {}
        expect(composition).not_to have_key('O2'),
          "#{template['identifier']} incorrectly contains oxygen"
      end
    end
  end

  describe 'sanity checks' do
    it 'has realistic gravity values' do
      json['terrestrial_planets'].each do |t|
        expect(t['gravity']).to be_between(0.5, 1.5)
      end
    end

    it 'has positive pressure' do
      json['terrestrial_planets'].each do |t|
        expect(t['known_pressure']).to be > 0
      end
    end

    it 'terraforming difficulty is bounded' do
      json['terrestrial_planets'].each do |t|
        expect(t['terraforming_difficulty']).to be_between(1.0, 10.0)
      end
    end
  end
end
