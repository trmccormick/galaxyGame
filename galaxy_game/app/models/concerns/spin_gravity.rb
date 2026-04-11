module SpinGravity
  extend ActiveSupport::Concern
  
  included do
    # This persists the current spin state of the structure
    attribute :rotation_rpm, :float, default: 0.0
  end
  
  def artificial_gravity_g
    return 0 unless needs_spin_gravity? && rotation_rpm.present? && diameter_m.to_f > 0
    
    # Standard Angular Velocity: ω = (RPM * π) / 30
    omega = rotation_rpm * Math::PI / 30
    # Centripetal Acceleration: a = ω² * r
    # Divided by 9.81 to get G-force
    (omega**2 * (diameter_m / 2)) / 9.81
  end
  
  def needs_spin_gravity?
    # Gate: Only applies to microgravity environments (Orbitals/Asteroids)
    location&.gravity_g.to_f < 0.01
  end
  
  def spin_for_gravity(target_g: 0.95)
    return unless needs_spin_gravity?
    self.rotation_rpm = target_rotation_rpm(target_g)
    save!
  end

  private

  def target_rotation_rpm(target_g)
    return 0 unless diameter_m.to_f > 0
    # Solve for omega: ω = sqrt( (g * 9.81) / r )
    omega = Math.sqrt((target_g * 9.81) / (diameter_m / 2))
    # Convert back to RPM
    (omega * 30 / Math::PI).round(2)
  end
end