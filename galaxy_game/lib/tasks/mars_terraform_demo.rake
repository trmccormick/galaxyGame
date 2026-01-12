# lib/tasks/mars_terraform_demo.rake
# Advanced Mars terraforming demonstration for AI training
# Shows biosphere seeding, atmospheric changes, and long-term planetary evolution

namespace :mars do
  desc "Advanced terraforming demo: AI-guided biosphere seeding and 10,000-year simulation"
  task terraform_demo: :environment do
    puts "\n" + "="*90
    puts "🌍 MARS TERRAFORMING AI DEMO - Planetary Engineering Training Module"
    puts "="*90
    puts "This demo showcases AI-driven biosphere engineering and atmospheric terraforming"
    puts "Learning Objectives: Biosphere seeding, gas exchange dynamics, long-term planetary evolution"
    puts ""

    # Initialize Mars
    mars = setup_mars_for_demo
    return unless mars

    # AI-guided biosphere seeding
    puts "\n🤖 AI BIOSPHERE SEEDING PHASE"
    puts "AI Manager analyzing Mars conditions for optimal life form selection..."
    seed_ai_optimized_biosphere(mars)

    # Pre-simulation assessment
    display_planetary_state(mars, "PRE-TERRAFORMING ASSESSMENT")

    # Long-term simulation with AI monitoring
    puts "\n🚀 AI-ORCHESTRATED TERRAFORMING SIMULATION"
    puts "Running 10,000-year biosphere evolution with continuous AI optimization..."
    run_ai_terraforming_simulation(mars)

    # Final assessment
    display_planetary_state(mars, "POST-TERRAFORMING ASSESSMENT")

    # AI analysis and recommendations
    provide_ai_analysis(mars)

    puts "\n✅ TERRAFORMING DEMO COMPLETE"
    puts "AI Manager has successfully demonstrated planetary engineering capabilities"
    puts "="*90 + "\n"
  end

  def setup_mars_for_demo
    mars = CelestialBodies::CelestialBody.find_by(name: 'Mars')
    if mars.nil?
      puts "🔧 Setting up Mars for terraforming demonstration..."
      mars = CelestialBodies::CelestialBody.create!(
        name: "Mars",
        identifier: "MARS-01",
        type: "CelestialBodies::CelestialBody",
        size: 0.532,
        mass: 6.42e23,
        radius: 3.389e6,
        density: 3.933,
        orbital_period: 687,
        surface_temperature: 210,
        gravity: 3.721,
        known_pressure: 0.006
      )

      # Create Mars-like atmosphere (thin, CO2-dominated)
      mars.create_atmosphere!(
        composition: {
          "CO2" => { "percentage" => 95.32 },
          "N2" => { "percentage" => 2.7 },
          "Ar" => { "percentage" => 1.6 }
        },
        pressure: 0.006,
        total_atmospheric_mass: 2.5e16,
        temperature: 210.0
      )

      # Create Mars-like hydrosphere (mostly frozen)
      mars.create_hydrosphere!(
        composition: { "H2O" => { "percentage" => 100.0 } },
        total_hydrosphere_mass: 2.1e17,
        state_distribution: {
          "solid" => { "percentage" => 99.5 },
          "liquid" => { "percentage" => 0.5 },
          "gas" => { "percentage" => 0.0 }
        }
      )
      puts "✅ Mars created with realistic initial conditions"
    end
    mars
  end

  def seed_ai_optimized_biosphere(mars)
    biosphere = mars.biosphere || mars.create_biosphere!(habitable_ratio: 0.001, biodiversity_index: 0.0)

    if biosphere.life_forms.count == 0
      puts "🌱 AI selecting optimal pioneer species for Mars conditions..."

      # AI-optimized life forms with realistic production rates
      species_config = [
        {
          name: "Extremophile Cyanobacteria",
          population: 500_000_000_000, # 5e11 - more realistic for global distribution
          properties: {
            'oxygen_production_rate' => 0.001,  # Much higher per organism
            'co2_consumption_rate' => 0.0012,
            'nitrogen_fixation_rate' => 0.0001,
            'preferred_biome' => 'Regolith',
            'min_temperature' => 170.0,
            'max_temperature' => 320.0,
            'description' => 'Photosynthetic pioneers producing O2 and fixing nitrogen'
          }
        },
        {
          name: "Psychrophilic Algae",
          population: 200_000_000_000, # 2e11
          properties: {
            'oxygen_production_rate' => 0.0015,
            'co2_consumption_rate' => 0.0018,
            'preferred_biome' => 'Polar Cap',
            'min_temperature' => 180.0,
            'max_temperature' => 310.0,
            'description' => 'Cold-adapted algae for polar regions'
          }
        },
        {
          name: "Methanogenic Archaea",
          population: 100_000_000_000, # 1e11
          properties: {
            'methane_production_rate' => 0.0008,
            'co2_consumption_rate' => 0.0005,
            'preferred_biome' => 'Subsurface',
            'min_temperature' => 160.0,
            'max_temperature' => 330.0,
            'description' => 'Methane producers creating greenhouse gas'
          }
        }
      ]

      species_config.each do |config|
        Biology::LifeForm.create!(
          biosphere: biosphere,
          name: config[:name],
          complexity: :simple,
          population: config[:population],
          diet: config[:name].include?('Methanogenic') ? 'chemosynthetic' : 'photosynthetic',
          properties: config[:properties]
        )
        puts "  ✓ Seeded #{config[:name]}: #{config[:population].to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')} organisms"
      end

      puts "✅ AI biosphere seeding complete - #{species_config.sum { |s| s[:population] }.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')} total organisms"
    end
  end

  def display_planetary_state(mars, title)
    atmosphere = mars.atmosphere
    hydrosphere = mars.hydrosphere
    biosphere = mars.biosphere

    puts "\n📊 #{title}"
    puts "─" * 50

    if atmosphere
      puts "🌬️  Atmosphere:"
      puts "    Pressure: #{atmosphere.pressure} bar"
      puts "    Temperature: #{atmosphere.temperature}K"
      puts "    Mass: #{atmosphere.total_atmospheric_mass.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')} kg"
      puts "    Composition:"
      atmosphere.composition.each do |gas, data|
        percentage = data['percentage'] || data[:percentage] || 0
        puts "      #{gas}: #{percentage.round(4)}%"
      end
    end

    if hydrosphere
      puts "💧 Hydrosphere:"
      puts "    Total Mass: #{hydrosphere.total_hydrosphere_mass.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')} kg"
      puts "    State Distribution:"
      hydrosphere.state_distribution.each do |state, data|
        percentage = data['percentage'] || data[:percentage] || 0
        puts "      #{state.capitalize}: #{percentage}%"
      end
    end

    if biosphere
      puts "🌿 Biosphere:"
      puts "    Habitability: #{(biosphere.habitable_ratio * 100).round(3)}%"
      puts "    Biodiversity Index: #{biosphere.biodiversity_index.round(3)}"
      puts "    Species Count: #{biosphere.life_forms.count}"
      total_population = biosphere.life_forms.sum(:population)
      puts "    Total Population: #{total_population.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')} organisms"

      puts "    Species Details:"
      biosphere.life_forms.each do |life_form|
        puts "      • #{life_form.name}: #{life_form.population.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')} organisms"
      end
    end
  end

  def run_ai_terraforming_simulation(mars)
    # Key milestones for AI monitoring
    milestones = [1, 10, 100, 1000, 5000, 10000]

    service = TerraSim::BiosphereSimulationService.new(mars)
    previous_day = 0

    milestones.each do |target_day|
      days_to_simulate = target_day - previous_day
      puts "\n⏰ Simulating days #{previous_day + 1}-#{target_day}..."

      service.simulate(days_to_simulate)

      # Reload data
      mars.atmosphere.reload if mars.atmosphere
      mars.hydrosphere.reload if mars.hydrosphere
      mars.biosphere.reload if mars.biosphere

      # AI analysis at milestone
      analyze_milestone_progress(mars, target_day)

      previous_day = target_day
    end
  end

  def analyze_milestone_progress(mars, day)
    atmosphere = mars.atmosphere
    biosphere = mars.biosphere

    puts "📈 Day #{day} Analysis:"
    puts "    Atmospheric Changes:"
    puts "      O₂:  #{atmosphere&.o2_percentage&.round(6) || 0}%"
    puts "      CO₂: #{atmosphere&.co2_percentage&.round(4) || 0}%"
    puts "      CH₄: #{atmosphere&.ch4_percentage&.round(6) || 0}%"

    habitability = (biosphere.habitable_ratio * 100).round(3)
    puts "    Biosphere Metrics:"
    puts "      Habitability: #{habitability}%"
    puts "      Total Organisms: #{biosphere.life_forms.sum(:population).to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')}"

    # AI insights
    if day >= 1000
      if habitability > 1.0
        puts "    🤖 AI Insight: Biosphere showing early signs of establishment"
      elsif atmosphere&.o2_percentage.to_f > 0.1
        puts "    🤖 AI Insight: Oxygen production accelerating - greenhouse effect building"
      end
    end
  end

  def provide_ai_analysis(mars)
    atmosphere = mars.atmosphere
    biosphere = mars.biosphere

    puts "\n🧠 AI TERRAFORMING ANALYSIS & RECOMMENDATIONS"
    puts "=" * 60

    # Atmospheric analysis
    o2_level = atmosphere&.o2_percentage.to_f || 0
    co2_level = atmosphere&.co2_percentage.to_f || 0
    ch4_level = atmosphere&.ch4_percentage.to_f || 0

    puts "🌬️ Atmospheric Evolution:"
    puts "  • O₂ production: #{o2_level > 0.01 ? 'SUCCESSFUL' : 'MINIMAL'} (#{o2_level.round(4)}%)"
    puts "  • CO₂ consumption: #{co2_level < 95 ? 'ACTIVE' : 'STAGNANT'} (#{co2_level.round(2)}% remaining)"
    puts "  • CH₄ greenhouse: #{ch4_level > 0.01 ? 'CONTRIBUTING' : 'NEGATIVE'} (#{ch4_level.round(4)}%)"

    # Biosphere analysis
    habitability = (biosphere.habitable_ratio * 100)
    total_population = biosphere.life_forms.sum(:population)

    puts "\n🌿 Biosphere Development:"
    puts "  • Habitability: #{habitability.round(3)}% (Target: >50% for complex life)"
    puts "  • Population: #{total_population.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')} organisms"
    puts "  • Species: #{biosphere.life_forms.count} pioneer species established"

    # AI recommendations
    puts "\n🎯 AI Recommendations for Full Terraforming:"
    puts "  1. Continue O₂ production - Current rate supports gradual atmospheric thickening"
    puts "  2. Enhance CH₄ production - Additional methanogens needed for greenhouse warming"
    puts "  3. Temperature optimization - Polar algae expansion could accelerate warming"
    puts "  4. Scale up population - Current biosphere needs 1000x growth for significant impact"
    puts "  5. Monitor gas ratios - O₂ levels must stay below 25% to prevent toxicity"

    puts "\n📚 Training Insights:"
    puts "  • Biosphere engineering requires patience - 10,000 years for meaningful change"
    puts "  • Multi-species approaches provide resilience against environmental fluctuations"
    puts "  • Gas exchange rates compound over time - early establishment is critical"
    puts "  • AI monitoring enables optimization of life form selection and distribution"
  end
end
