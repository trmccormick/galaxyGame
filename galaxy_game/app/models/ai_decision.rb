# Placeholder AiDecision model for admin dashboard and AI monitoring UI integration
# Fields based on design_phase_4b_ui_enhancements.md

class AiDecision
  # Simulate ActiveRecord attributes for placeholder/testing
  attr_accessor :id, :type, :content, :impact, :confidence, :timestamp, :settlement

  def initialize(id: 1, type: 'resource', content: 'Allocate water to Mars Base Alpha', impact: 'Resource +10%', confidence: 0.92, timestamp: Time.now, settlement: 'Mars Base Alpha')
    @id = id
    @type = type
    @content = content
    @impact = impact
    @confidence = confidence
    @timestamp = timestamp
    @settlement = settlement
  end

  # Example: return a list of mock decisions for testing
  def self.recent(limit = 5)
    [
      new(id: 1, type: 'resource', content: 'Allocate water to Mars Base Alpha', impact: 'Resource +10%', confidence: 0.92, timestamp: 1.hour.ago, settlement: 'Mars Base Alpha'),
      new(id: 2, type: 'expansion', content: 'Expand Luna Outpost', impact: 'Capacity +5', confidence: 0.85, timestamp: 2.hours.ago, settlement: 'Luna Outpost'),
      new(id: 3, type: 'crisis', content: 'Respond to power outage on Europa', impact: 'Crisis resolved', confidence: 0.78, timestamp: 3.hours.ago, settlement: 'Europa'),
      new(id: 4, type: 'coordination', content: 'Coordinate supply transfer to Earth Hub', impact: 'Transfer started', confidence: 0.88, timestamp: 4.hours.ago, settlement: 'Earth Hub'),
      new(id: 5, type: 'resource', content: 'Redistribute food supplies', impact: 'Resource +5%', confidence: 0.81, timestamp: 5.hours.ago, settlement: 'Mars Base Alpha')
    ].first(limit)
  end
end
