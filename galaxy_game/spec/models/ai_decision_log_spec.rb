require 'rails_helper'

describe AiDecisionLog, type: :model do
  let(:celestial_body) {
    CelestialBodies::CelestialBody.create!(
      name: 'TestBody',
      identifier: 'TEST-001',
      type: 'CelestialBodies::Planets::Rocky::TerrestrialPlanet',
      size: 1000,
      mass: 5.97e24
    )
  }

  it 'is valid with valid attributes' do
    log = AiDecisionLog.new(
      celestial_body: celestial_body,
      location_context: 'sector-1',
      decision_type: 'resource_allocation',
      reasoning: 'AI chose optimal resource allocation.',
      constraints: { max_energy: 100 },
      outcome: { success: true },
      metadata: { ai_version: '1.0' }
    )
    expect(log).to be_valid
  end

  it 'is invalid without required fields' do
    log = AiDecisionLog.new
    expect(log).not_to be_valid
    expect(log.errors[:location_context]).to be_present
    expect(log.errors[:decision_type]).to be_present
    expect(log.errors[:reasoning]).to be_present
  end

  it 'can filter by celestial body and location' do
    log1 = AiDecisionLog.create!(celestial_body: celestial_body, location_context: 'sector-1', decision_type: 'move', reasoning: 'Test', constraints: {}, outcome: {}, metadata: {})
    log2 = AiDecisionLog.create!(celestial_body: celestial_body, location_context: 'sector-2', decision_type: 'move', reasoning: 'Test', constraints: {}, outcome: {}, metadata: {})
    expect(AiDecisionLog.for_body(celestial_body.id).count).to eq(2)
    expect(AiDecisionLog.at_location('sector-1').count).to eq(1)
  end
end
