require 'rails_helper'

RSpec.describe Biology::LifeForm, type: :model do
  let(:biosphere) { create(:biosphere, habitable_ratio: 1.0) }
  let(:life_form) { create(:life_form, biosphere: biosphere, population: 1000) }
  
  describe "inheritance" do
    it "inherits from BaseLifeForm" do
      expect(described_class.superclass).to eq(Biology::BaseLifeForm)
    end
  end
  
  describe "#type_identifier" do
    it "returns 'natural'" do
      expect(life_form.type_identifier).to eq("natural")
    end
  end
  
  describe "#adapt_to_environment" do
    context "with poor adaptation score" do
      it "reduces population" do
        initial_population = life_form.population
        life_form.adapt_to_environment({ temperature: 0.1, humidity: 0.2 })
        
        expect(life_form.population).to be < initial_population
        expect(life_form.population).to eq((initial_population * 0.8).to_i)
      end
    end
    
    context "with neutral adaptation score" do
      it "keeps population stable" do
        initial_population = life_form.population
        life_form.adapt_to_environment({ temperature: 0.4, humidity: 0.5 })
        
        expect(life_form.population).to eq(initial_population)
      end
    end
    
    context "with good adaptation score" do
      it "increases population" do
        initial_population = life_form.population
        life_form.adapt_to_environment({ temperature: 0.8, humidity: 0.9 })
        
        expect(life_form.population).to be > initial_population
        expect(life_form.population).to eq((initial_population * 1.2).to_i)
      end
    end
  end
  
  describe "#simulate_growth" do
    it "uses _calculate_base_growth_rate to modify population" do
      # Ensure biosphere has habitability set
      biosphere = create(:biosphere, habitable_ratio: 1.0)
      life_form = create(:life_form, biosphere: biosphere, population: 1000)
      
      # Mock the protected method to return 1.3
      allow(life_form).to receive(:_calculate_base_growth_rate).and_return(1.3)
      
      initial_population = life_form.population
      life_form.simulate_growth
      
      # 1000 * 1.3 * 1.0 = 1300
      expect(life_form.population).to eq((initial_population * 1.3).to_i)
    end
    
    it "is affected by biosphere habitability" do
      # Create a biosphere with reduced habitability
      biosphere = create(:biosphere, habitable_ratio: 0.5)
      life_form = create(:life_form, biosphere: biosphere, population: 1000)
      
      # Allow the actual growth rate calculation
      allow(life_form).to receive(:_calculate_base_growth_rate).and_call_original
      
      # Compare with a life form in a perfect biosphere
      perfect_biosphere = create(:biosphere, habitable_ratio: 1.0)
      perfect_life_form = create(:life_form, 
                                 biosphere: perfect_biosphere, 
                                 complexity: life_form.complexity, 
                                 population: life_form.population)
      
      # Allow the actual growth rate calculation for perfect life form too
      allow(perfect_life_form).to receive(:_calculate_base_growth_rate).and_call_original
      
      # Run simulation and compare
      life_form.simulate_growth
      perfect_life_form.simulate_growth
      
      expect(life_form.population).to be < perfect_life_form.population
    end
  end

  describe "#total_biomass" do
    context "with custom mass in properties" do
      it "uses custom mass instead of complexity-based calculation" do
        biosphere = create(:biosphere)
        life_form = create(:life_form, 
                          biosphere: biosphere,
                          complexity: :simple,  # Would normally be 0.01
                          population: 1000,
                          properties: { 'mass' => 5.0 })
        
        # Should use custom mass (5.0) not complexity multiplier (0.01)
        expect(life_form.total_biomass).to eq(5000.0)  # 1000 * 5.0
      end
    end
    
    context "without custom mass in properties" do
      it "falls back to complexity-based calculation" do
        biosphere = create(:biosphere)
        life_form = create(:life_form,
                          biosphere: biosphere,
                          complexity: :simple,
                          population: 1000)
        
        # Should use complexity multiplier (0.01)
        expect(life_form.total_biomass).to eq(10.0)  # 1000 * 0.01
      end
    end
  end
  
  describe "#atmospheric_contribution" do
    context "with no population" do
      it "returns zero contribution" do
        life_form = create(:life_form, 
                          biosphere: biosphere,
                          population: 0,
                          oxygen_production_rate: 0.1)
        
        contribution = life_form.atmospheric_contribution
        
        expect(contribution[:o2]).to eq(0.0)
        expect(contribution[:co2]).to eq(0.0)
        expect(contribution[:ch4]).to eq(0.0)
        expect(contribution[:n2]).to eq(0.0)
        expect(contribution[:soil]).to eq(0.0)
      end
    end
    
    context "with photosynthetic organism" do
      it "calculates oxygen production and CO2 consumption" do
        life_form = create(:life_form,
                          biosphere: biosphere,
                          population: 1_000_000_000, # 1 billion
                          oxygen_production_rate: 0.1,
                          co2_consumption_rate: 0.15)
        
        contribution = life_form.atmospheric_contribution
        
        # At 1 billion population (scale = 1.0):
        # O2 = 0.1 * 1.0 = 0.1
        # CO2 = 0.15 * 1.0 = 0.15
        expect(contribution[:o2]).to eq(0.1)
        expect(contribution[:co2]).to eq(0.15)
        expect(contribution[:ch4]).to eq(0.0)
      end
    end
    
    context "with methane-producing organism" do
      it "calculates methane production" do
        life_form = create(:life_form,
                          biosphere: biosphere,
                          population: 500_000_000, # 0.5 billion
                          methane_production_rate: 0.05)
        
        contribution = life_form.atmospheric_contribution
        
        # At 500 million population (scale = 0.5):
        # CH4 = 0.05 * 0.5 = 0.025
        expect(contribution[:ch4]).to eq(0.025)
      end
    end
    
    context "with nitrogen-fixing organism" do
      it "calculates nitrogen fixation" do
        life_form = create(:life_form,
                          biosphere: biosphere,
                          population: 2_000_000_000, # 2 billion
                          nitrogen_fixation_rate: 0.08)
        
        contribution = life_form.atmospheric_contribution
        
        # At 2 billion population (scale = 2.0):
        # N2 = 0.08 * 2.0 = 0.16
        expect(contribution[:n2]).to eq(0.16)
      end
    end
    
    context "with soil-improving organism" do
      it "calculates soil improvement" do
        life_form = create(:life_form,
                          biosphere: biosphere,
                          population: 1_000_000_000,
                          soil_improvement_rate: 0.03)
        
        contribution = life_form.atmospheric_contribution
        
        expect(contribution[:soil]).to eq(0.03)
      end
    end
    
    context "with multiple effects" do
      it "returns all contributions" do
        life_form = create(:life_form,
                          biosphere: biosphere,
                          population: 1_000_000_000,
                          oxygen_production_rate: 0.1,
                          co2_consumption_rate: 0.05,
                          methane_production_rate: 0.01,
                          nitrogen_fixation_rate: 0.02,
                          soil_improvement_rate: 0.03)
        
        contribution = life_form.atmospheric_contribution
        
        expect(contribution[:o2]).to eq(0.1)
        expect(contribution[:co2]).to eq(0.05)
        expect(contribution[:ch4]).to eq(0.01)
        expect(contribution[:n2]).to eq(0.02)
        expect(contribution[:soil]).to eq(0.03)
      end
    end
    
    context "with population scaling" do
      it "scales contributions by population size" do
        small_pop = create(:life_form,
                          biosphere: biosphere,
                          population: 100_000_000, # 0.1 billion
                          oxygen_production_rate: 0.1)

        large_pop = create(:life_form,
                          biosphere: biosphere,
                          population: 10_000_000_000, # 10 billion
                          oxygen_production_rate: 0.1)

        small_contribution = small_pop.atmospheric_contribution
        large_contribution = large_pop.atmospheric_contribution

        # Large population should contribute 100x more (10 / 0.1 = 100)
        expect(large_contribution[:o2]).to be_within(0.0001).of(small_contribution[:o2] * 100)
      end
    end
  end
end