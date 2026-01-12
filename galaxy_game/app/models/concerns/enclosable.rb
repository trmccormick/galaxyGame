# app/models/concerns/enclosable.rb
module Enclosable
  extend ActiveSupport::Concern

  included do
    # Enclosable specific associations and validations
  end

  # Dimensional methods
  def area_m2
    if respond_to?(:diameter_m) && diameter_m
      Math::PI * (diameter_m / 2.0) ** 2
    else
      width_m * length_m
    end
  end

  def calculate_enclosure_materials
    # Dummy
    {}
  end

  def total_power_generation
    # Dummy calculation
    0
  end

  def simulate_panel_degradation(days)
    # Dummy
  end
end