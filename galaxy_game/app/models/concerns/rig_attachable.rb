# app/models/concerns/rig_attachable.rb
module RigAttachable
  extend ActiveSupport::Concern

  included do
    # Unify access for any specs or callers expecting :persisted_rigs
    if method_defined?(:base_rigs)
      alias_method :persisted_rigs, :base_rigs
    elsif method_defined?(:rigs)
      alias_method :persisted_rigs, :rigs
    end
  end

  def update_consumables(resource, delta)
    self.operational_data ||= {}
    operational_data['consumables'] ||= {}
    operational_data['consumables'][resource] ||= 0
    operational_data['consumables'][resource] += delta
    operational_data['consumables'][resource] = [operational_data['consumables'][resource], 0].max
    save!
  end

  def update_outputs(resource, delta)
    self.operational_data ||= {}
    operational_data['output_resources'] ||= {}
    operational_data['output_resources'][resource] ||= 0
    operational_data['output_resources'][resource] += delta
    operational_data['output_resources'][resource] = [operational_data['output_resources'][resource], 0].max
    save!
  end

  def update_damage_risks(risk_type, delta)
    self.operational_data ||= {}
    operational_data['damage_risks'] ||= {}
    operational_data['damage_risks'][risk_type] ||= 0
    operational_data['damage_risks'][risk_type] += delta
    operational_data['damage_risks'][risk_type] = [operational_data['damage_risks'][risk_type], 0].max
    save!
  end
end
