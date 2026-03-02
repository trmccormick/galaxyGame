# == Schema Information
#
# Table name: ai_decision_logs
#
#  id               :bigint           not null, primary key
#  celestial_body_id :bigint           not null
#  location_context :string           not null
#  decision_type    :string           not null
#  reasoning        :text             not null
#  constraints      :text
#  outcome          :text
#  metadata         :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class AiDecisionLog < ApplicationRecord
  belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody'

  validates :location_context, :decision_type, :reasoning, presence: true

  serialize :constraints, JSON
  serialize :outcome, JSON

  # Optionally, add scopes for admin filtering
  scope :for_body, ->(body_id) { where(celestial_body_id: body_id) }
  scope :at_location, ->(loc) { where(location_context: loc) }
end
