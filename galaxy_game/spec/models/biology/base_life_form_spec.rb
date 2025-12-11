# File: spec/models/biology/base_life_form_spec.rb
require 'rails_helper'

RSpec.describe Biology::BaseLifeForm, type: :model do
  describe "associations" do
    it { should belong_to(:biosphere) }
  end
  
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:population).is_greater_than_or_equal_to(0) }
  end
  
  describe "enums" do
    it { should define_enum_for(:complexity).with_values(microbial: 0, simple: 1, complex: 2, intelligent: 3) }
    it { should define_enum_for(:domain).with_values(aquatic: 0, terrestrial: 1, aerial: 2, subterranean: 3) }
  end
  
  describe "attributes" do
    it "stores additional properties in the properties column" do
      life_form = create(:life_form, 
                          diet: "herbivore", 
                          prey_for: ["carnivore", "omnivore"], 
                          description: "A test organism")
      
      expect(life_form.diet).to eq("herbivore")
      expect(life_form.prey_for).to eq(["carnivore", "omnivore"])
      expect(life_form.description).to eq("A test organism")
    end
    
    # NEW: Test terraforming properties
    it "stores terraforming properties" do
      life_form = create(:life_form,
                        oxygen_production_rate: 0.1,
                        co2_consumption_rate: 0.15,
                        nitrogen_fixation_rate: 0.08)
      
      expect(life_form.oxygen_production_rate).to eq(0.1)
      expect(life_form.co2_consumption_rate).to eq(0.15)
      expect(life_form.nitrogen_fixation_rate).to eq(0.08)
    end
  end
  
  describe "#total_biomass" do
    it "calculates biomass differently based on complexity" do
      biosphere = create(:biosphere)
      
      microbial = create(:hybrid_life_form, biosphere: biosphere, complexity: :microbial, population: 1_000_000)
      simple = create(:hybrid_life_form, biosphere: biosphere, complexity: :simple, population: 1_000)
      complex = create(:hybrid_life_form, biosphere: biosphere, complexity: :complex, population: 100)
      intelligent = create(:hybrid_life_form, biosphere: biosphere, complexity: :intelligent, population: 10)
      
      expect(microbial.total_biomass).to be_within(0.1).of(1.0)
      expect(simple.total_biomass).to be_within(0.1).of(10.0)
      expect(complex.total_biomass).to be_within(0.1).of(100.0)
      expect(intelligent.total_biomass).to be_within(0.1).of(500.0)
    end
  end
  
  # NEW: Test atmospheric contribution
  describe "#atmospheric_contribution" do
    let(:biosphere) { create(:biosphere) }
    
    context "with terraforming properties set" do
      it "calculates atmospheric effects based on population" do
        life_form = create(:life_form,
                          biosphere: biosphere,
                          population: 1_000_000_000, # 1 billion
                          oxygen_production_rate: 0.1,
                          co2_consumption_rate: 0.15,
                          methane_production_rate: 0.05,
                          nitrogen_fixation_rate: 0.08)
        
        contribution = life_form.atmospheric_contribution
        
        # 1 billion / 1 billion = 1.0 scale factor
        expect(contribution[:o2]).to eq(0.1)
        expect(contribution[:co2]).to eq(0.15)
        expect(contribution[:ch4]).to eq(0.05)
        expect(contribution[:n2]).to eq(0.08)
      end
      
      it "scales effects by population size" do
        life_form = create(:life_form,
                          biosphere: biosphere,
                          population: 500_000_000, # 0.5 billion
                          oxygen_production_rate: 0.1)
        
        contribution = life_form.atmospheric_contribution
        
        # 500 million / 1 billion = 0.5 scale factor
        expect(contribution[:o2]).to eq(0.05)
      end
    end
    
    context "with zero population" do
      it "returns zero effects" do
        life_form = create(:life_form,
                          biosphere: biosphere,
                          population: 0,
                          oxygen_production_rate: 0.1)
        
        contribution = life_form.atmospheric_contribution
        
        # Returns structured hash with zero values (not empty hash)
        expect(contribution).to eq({ ch4: 0.0, co2: 0.0, n2: 0.0, o2: 0.0, soil: 0.0 })
      end
    end
    
    context "without terraforming properties" do
      it "returns zero effects" do
        life_form = create(:life_form,
                          biosphere: biosphere,
                          population: 1_000_000_000)
        
        contribution = life_form.atmospheric_contribution
        
        expect(contribution[:o2]).to eq(0.0)
        expect(contribution[:co2]).to eq(0.0)
      end
    end
  end
  
  describe "#type_identifier" do
    it "raises NotImplementedError when called on base class" do
      biosphere = create(:biosphere)
      life_form = Biology::BaseLifeForm.new(
        name: "Test",
        biosphere: biosphere,
        complexity: :simple,
        domain: :terrestrial
      )
      
      expect { life_form.type_identifier }.to raise_error(NotImplementedError)
    end
  end
end