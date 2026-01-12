# app/models/concerns/terraforming_concern.rb
module TerraformingConcern
  extend ActiveSupport::Concern

  included do
    # Ensure the TerraformingProject model exists and is correctly defined.
    # It must have a 'target_celestial_body_id' foreign key.
    # Example:
    # class TerraformingProject < ApplicationRecord
    #   belongs_to :target_celestial_body, class_name: 'CelestialBodies::CelestialBody'
    #   enum status: { active: 0, completed: 1, cancelled: 2 }
    #   # Add process_cycle method and any other necessary logic
    #   def process_cycle
    #     # Logic to advance the terraforming project
    #     puts "Processing terraforming cycle for project #{id} on #{target_celestial_body.name}"
    #   end
    # end

    # Uncomment the following line if you have a TerraformingProject model
    # and it has the necessary associations and methods defined.
    # Ensure the model is defined in the correct namespace if using STI
    # belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody', optional: true
    # Uncomment if you want to use a has_many association for terraforming projects
    # This assumes you have a TerraformingProject model defined in the same namespace
    # has_many :terraforming_projects,
    #          class_name: 'TerraformingProject',
    #          foreign_key: 'target_celestial_body_id',
    #          dependent: :destroy
  end

  # Returns true if this body has active terraforming projects.
  # Requires a 'TerraformingProject' model with an 'active' enum status or scope.
  def terraforming_active?
    terraforming_projects.exists?(status: :active) # Assuming 'status: :active' enum
    # OR if you have a scope:
    # terraforming_projects.active.exists?
  rescue NameError # Catch if TerraformingProject isn't defined yet
    false
  end

  # Calculate terraforming potential based on current state.
  # Requires `habitable_zone?`, `habitability_score`, `atmosphere`, `atmosphere.pressure`, `atmosphere_score`
  # methods to be defined in the including class.
  def terraforming_potential
    # If already highly habitable, no potential for terraforming (it's done)
    return :none if habitable_zone? && habitability_score.to_f > 0.8

    # Check if atmosphere exists and has a pressure attribute
    unless atmosphere.present? && atmosphere.respond_to?(:pressure)
      return :unknown # Cannot assess potential without atmospheric data
    end

    if habitable_zone?
      # Planet is in the habitable zone but needs work
      if atmosphere.pressure.to_f < 0.1 # Very thin or no atmosphere
        return :high # Needs atmosphere but in habitable zone
      elsif atmosphere_score.to_f < 0.5 # Has atmosphere but wrong composition
        return :medium # Needs atmospheric composition adjustment
      else
        return :low # Almost Earth-like already, minor tweaks needed
      end
    else
      # Outside habitable zone, very difficult
      return :extreme # Outside habitable zone, will be very difficult
    end
  end

  # Process all active terraforming projects associated with this celestial body.
  # Requires 'TerraformingProject' model with an 'active' scope and 'process_cycle' method.
  def process_terraforming_cycle
    return unless terraforming_active?

    # Using .find_each for large collections to avoid loading all into memory
    terraforming_projects.active.find_each do |project|
      project.process_cycle # Assumes TerraformingProject has this method
    end
  rescue NameError => e
    Rails.logger.error "TerraformingProject not found or misconfigured: #{e.message}"
    # Handle the error gracefully, e.g., log it, or skip processing
  end

  # Estimate time to make this planet habitable.
  # Requires `habitability_score`, `atmosphere`, `mass`, `atmosphere_score` methods.
  # @param options [Hash] Custom options for the estimation.
  #   :fleet_size [Integer] Number of terraforming fleets.
  #   :vehicle_capacity [Float] Capacity of each vehicle (e.g., kg/trip).
  #   :target_score [Float] The desired habitability score.
  # @return [Integer] Estimated years needed, or 0 if already habitable.
  def time_to_habitability(options = {})
    # Default options
    options = {
      fleet_size: 10_000,
      vehicle_capacity: 1.0e12, # kg per vehicle
      target_score: 0.7
    }.merge(options)

    # Current habitability
    current_score = habitability_score.to_f # Ensure float comparison

    # Nothing to do if already habitable
    return 0 if current_score >= options[:target_score]

    # Ensure atmosphere and mass are available for calculations
    unless atmosphere.present? && atmosphere.respond_to?(:pressure) && mass.present?
      Rails.logger.warn "Cannot estimate time to habitability for #{name}: Missing atmosphere or mass data."
      return Float::INFINITY # Indicate impossible or uncalculable
    end

    # Get pressure difference needed
    target_pressure = 1.0 # Earth-like pressure in atmospheres (or whatever unit you use)
    current_pressure = atmosphere.pressure.to_f
    pressure_diff = target_pressure - current_pressure

    # Calculate fleet capacity per year, guarding against division by zero
    fleet_capacity_per_year = options[:fleet_size].to_f * options[:vehicle_capacity].to_f * 4 # ~4 trips/year
    if fleet_capacity_per_year <= 0
      Rails.logger.warn "Cannot estimate time to habitability: Fleet capacity is zero or negative."
      return Float::INFINITY
    end

    # Rough estimate for adding atmosphere (if needed)
    # Using 'mass' directly from the including CelestialBody
    years_needed_for_pressure = if pressure_diff > 0
      # This formula is highly simplified; adjust based on your game's physics model
      # Consider the total mass of atmosphere needed vs. fleet's capacity
      (pressure_diff * mass.to_f * 0.001 / fleet_capacity_per_year).ceil
    else
      0 # No need to add atmosphere
    end

    # Add time for atmospheric composition adjustment
    composition_adjustment_years = if atmosphere_score.to_f < 0.5
      50 # Rough estimate for major composition change
    elsif atmosphere_score.to_f < 0.8
      25 # Minor adjustments
    else
      0 # Good composition already
    end

    years_needed_for_pressure + composition_adjustment_years
  end
end
