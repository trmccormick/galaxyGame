module StarSim
  class OortCloudGenerator
    attr_reader :system, :random

    def initialize(system, random: Random.new)
      @system = system
      @random = random
    end

    def generate
      return nil unless generate_oort_cloud?

      {
        inner_radius_au: inner_radius,
        outer_radius_au: outer_radius,
        estimated_object_count: estimate_objects,
        icy_body_density: icy_density
      }
    end

    private

    def generate_oort_cloud?
      random.rand < 0.85
    end

    def inner_radius
      2_000 + random.rand(2_000..5_000)
    end

    def outer_radius
      inner_radius + random.rand(20_000..95_000)
    end

    def estimate_objects
      random.rand(10_000..1_000_000)
    end

    def icy_density
      random.rand(0.1..0.9)
    end
  end
end