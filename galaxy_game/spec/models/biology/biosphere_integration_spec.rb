# File: spec/models/biology/biosphere_integration_spec.rb
require 'rails_helper'

RSpec.describe "Biosphere and Life Form Integration", type: :model do
  let(:biosphere) { create(:biosphere, habitable_ratio: 1.0) } # ADD habitable_ratio!
  
  describe "ecosystem simulation" do
    before do
      # Create a simple ecosystem
      @plants = create(:life_form, biosphere: biosphere, 
               name: "Photosynthetic Plants",
               domain: :terrestrial,
               complexity: :simple,
               diet: "photosynthetic",
               population: 10_000)

      @herbivores = create(:life_form, biosphere: biosphere,
              name: "Herbivores",
              domain: :terrestrial,
              complexity: :complex,
              diet: "herbivore",
              population: 100_000,
              properties: { 'health_modifier' => 10.0, 'reproduction_rate' => 0.05 })

      @carnivores = create(
        :life_form,
        biosphere: biosphere,
        name: "Carnivores",
        domain: :terrestrial,
        complexity: :complex,
        diet: "carnivore",
        population: 10_000,
        properties: { 'health_modifier' => 10.0, 'reproduction_rate' => 0.1 }
      )

      @engineered = create(:hybrid_life_form, biosphere: biosphere,
              name: "Engineered Decomposers",
              domain: :terrestrial,
              complexity: :simple,
              diet: "decomposer",
              engineered_traits: ["efficient_decomposition"],
              population: 5_000)
    end
    
    it "simulates population dynamics" do
      # Run a simple ecosystem simulation with nonzero O2 for growth
      3.times do
        [@plants, @herbivores, @carnivores, @engineered].each do |life_form|
          life_form.simulate_growth(o2_percentage: 5.0, co2_percentage: 95.0, temperature: 250.0)
        end
      end

      # Verify that populations have changed
      expect(@plants.reload.population).not_to eq(10_000)
      expect(@herbivores.reload.population).not_to eq(100_000)
      expect(@carnivores.reload.population).not_to eq(10_000)
      expect(@engineered.reload.population).not_to eq(5_000)

      # Verify ecological relationships
      # All populations should still be positive (growing with habitable_ratio = 1.0)
      expect(@plants.population).to be > 0
      expect(@herbivores.population).to be > 0
      expect(@carnivores.population).to be > 0
      expect(@engineered.population).to be > 0
    end
    
    it "handles biosphere changes" do
      # Simulate a biosphere change (e.g., climate change)
      biosphere.update(habitable_ratio: 0.5) # Reduced habitability
      
      # Record populations before
      populations_before = {
        plants: @plants.population,
        herbivores: @herbivores.population,
        carnivores: @carnivores.population,
        engineered: @engineered.population
      }
      
      # Simulate growth with the new conditions
      [@plants, @herbivores, @carnivores, @engineered].each(&:simulate_growth)
      
      # All populations should grow more slowly or decline
      expect(@plants.reload.population).to be <= (populations_before[:plants] * 1.2).to_i
      expect(@herbivores.reload.population).to be <= (populations_before[:herbivores] * 1.2).to_i
      expect(@carnivores.reload.population).to be <= (populations_before[:carnivores] * 1.2).to_i
      
      # Engineered species might be more resilient
      if @engineered.engineered_traits.include?("environmental_adaptation")
        expect(@engineered.reload.population).to be > populations_before[:engineered]
      end
    end
  end
  
  describe "food availability calculation" do
    it "calculates food availability for herbivores" do
      herbivore = create(:life_form, biosphere: biosphere, 
                        properties: { 'diet' => 'herbivore' }, 
                        population: 100)
      create(:life_form, biosphere: biosphere, 
            properties: { 'diet' => 'photosynthetic' }, 
            population: 10_000)
      
      expect(herbivore.calculate_food_availability).to eq(100)
    end
    
    it "calculates food availability for carnivores" do
      # Create prey first
      prey = create(:life_form, biosphere: biosphere, 
                    name: "Prey Species",
                    properties: { 'diet' => 'herbivore' },
                    population: 1_000)
      
      # Create carnivore that preys on herbivores
      carnivore = create(:life_form, biosphere: biosphere, 
                        name: "Carnivore Species",
                        properties: { 
                          'diet' => 'carnivore',
                          'prey_for' => ['herbivore']
                        },
                        population: 50)
      
      # Food availability should be prey_population / 2 = 1000 / 2 = 500
      expect(carnivore.calculate_food_availability).to eq(500)
    end
    
    it "returns nil for photosynthetic life forms" do
      plant = create(:life_form, biosphere: biosphere, 
                    properties: { 'diet' => 'photosynthetic' }, 
                    population: 10_000)
      
      expect(plant.calculate_food_availability).to be_nil
    end
  end
  
  describe "environmental impact" do
    it "calculates the environmental impact of a life form" do
      life_form = create(:life_form, 
                        biosphere: biosphere, 
                        population: 1000,
                        domain: :terrestrial,
                        properties: {
                          'diet' => 'herbivore',
                          'o2_production_rate' => 0.1,
                          'co2_production_rate' => 0.05
                        })
                                  
      impact = life_form.environmental_impact
      
      expect(impact[:oxygen_change]).to eq(100)
      expect(impact[:co2_change]).to eq(50)
      expect(impact[:soil_quality_change]).to eq(0)
    end
    
    it "considers soil impact for decomposers" do
      decomposer = create(:hybrid_life_form, 
                          biosphere: biosphere, 
                          population: 500,
                          domain: :terrestrial,
                          properties: {
                            'diet' => 'decomposer',
                            'soil_improvement_rate' => 1.0
                          })
                                          
      impact = decomposer.environmental_impact
      
      # 1.0 * 500 / 10000 = 0.05
      expect(impact[:soil_quality_change]).to eq(0.05)
    end
  end
  
  describe "environmental impact" do
    it "calculates the environmental impact of a life form" do
      life_form = create(:life_form, 
                        biosphere: biosphere, 
                        population: 1000,
                        domain: :terrestrial)
      
      # Explicitly set properties using the accessor methods
      life_form.o2_production_rate = 0.1
      life_form.co2_production_rate = 0.05
      life_form.diet = 'herbivore'
      life_form.save!
      
      # Verify properties were set
      expect(life_form.o2_production_rate).to eq(0.1)
      expect(life_form.co2_production_rate).to eq(0.05)
                                
      impact = life_form.environmental_impact
      
      expect(impact[:oxygen_change]).to eq(100)
      expect(impact[:co2_change]).to eq(50)
      expect(impact[:soil_quality_change]).to eq(0)
    end
    
    it "considers soil impact for decomposers" do
      decomposer = create(:hybrid_life_form, 
                          biosphere: biosphere, 
                          population: 500,
                          domain: :terrestrial)
      
      # Explicitly set properties using the accessor methods
      decomposer.soil_improvement_rate = 1.0
      decomposer.diet = 'decomposer'
      decomposer.save!
      
      # Verify property was set
      expect(decomposer.soil_improvement_rate).to eq(1.0)
                                        
      impact = decomposer.environmental_impact
      
      # 1.0 * 500 / 10000 = 0.05
      expect(impact[:soil_quality_change]).to eq(0.05)
    end
  end
  
  describe "interactions" do
    it "handles interactions between different life forms" do
      herbivore = create(:life_form, biosphere: biosphere, diet: "herbivore", population: 100)
      carnivore = create(:life_form, biosphere: biosphere, diet: "carnivore", population: 50)
      plant = create(:life_form, biosphere: biosphere, diet: "photosynthetic", population: 10_000)
      
      # Establish predator-prey relationship
      carnivore.update(prey_for: ["herbivore"])
      
      # Simulate interactions
      [herbivore, carnivore, plant].each(&:interact_with)
      
      # Check that populations have adjusted
      expect(herbivore.reload.population).to eq(99) # Lost 1
      expect(carnivore.reload.population).to eq(51) # Gained 1
    end
  end
end