module SeedCalculators
  extend self

  def calculate_gravity(mass, radius)
    GameConstants.calculate_gravity(mass, radius)
  end
end