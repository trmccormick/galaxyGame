require 'rails_helper'

RSpec.describe Atmosphere, type: :model do
  let(:star) { create(:star) }
  let(:solar_system) { create(:solar_system, current_star: star) }
  let(:earth) { create(:terrestrial_planet, :earth, solar_system: solar_system) }
  
  describe "associations" do
    # ✅ FIX: Test celestial_body association instead of container
    it { should belong_to(:celestial_body).optional }
    it { should have_many(:gases).class_name('CelestialBodies::Materials::Gas').dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:enclosed_atmosphere, celestial_body: earth) }  # ✅ FIX
    
    it { should validate_presence_of(:environment_type) }
    it { should validate_numericality_of(:temperature) }
    it { should validate_numericality_of(:pressure).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:total_atmospheric_mass).is_greater_than_or_equal_to(0) }
  end

  describe "enums" do
    it "defines environment_type enum with string values" do
      expect(described_class.defined_enums['environment_type']).to eq({
        'planetary' => 'planetary',
        'enclosed' => 'enclosed',
        'artificial' => 'artificial',
        'hybrid' => 'hybrid'
      })
    end
  end

  describe "#volume" do
    context "when celestial_body responds to volume" do
      before do
        allow(earth).to receive(:volume).and_return(1000.0)
      end

      it "returns the celestial_body's volume" do
        atmosphere = build(:enclosed_atmosphere, celestial_body: earth)  # ✅ FIX
        expect(atmosphere.volume).to eq(1000.0)
      end
    end

    context "when celestial_body doesn't respond to volume" do
      let(:simple_celestial_body) { build_stubbed(:terrestrial_planet) }
      
      before do
        # Don't stub volume method so it returns nil/raises
        allow(simple_celestial_body).to receive(:respond_to?).with(:volume).and_return(false)
      end
      
      it "returns 0" do
        atmosphere = build(:enclosed_atmosphere, celestial_body: simple_celestial_body)
        expect(atmosphere.volume).to eq(0)
      end
    end
  end

  describe "sealing methods" do
    let(:atmosphere) { create(:enclosed_atmosphere, :sealed, celestial_body: earth) }  # ✅ FIX

    describe "#sealed?" do
      it "returns the sealing status" do
        expect(atmosphere.sealed?).to be true
      end
    end

    describe "#seal!" do
      let(:unsealed_atmosphere) { create(:enclosed_atmosphere, celestial_body: earth) }
      
      it "sets sealing status to true" do
        expect { unsealed_atmosphere.seal! }.to change { unsealed_atmosphere.sealing_status }.from(false).to(true)
      end
    end

    describe "#unseal!" do
      it "sets sealing status to false" do
        expect { atmosphere.unseal! }.to change { atmosphere.sealing_status }.from(true).to(false)
      end
    end
  end

  describe "#habitable?" do
    let(:atmosphere) { build(:enclosed_atmosphere, :earth_like, celestial_body: earth) }  # ✅ FIX

    context "with good conditions" do
      it "returns true" do
        expect(atmosphere.habitable?).to be true
      end
    end

    context "with low pressure" do
      it "returns false" do
        atmosphere.pressure = 0.5
        expect(atmosphere.habitable?).to be false
      end
    end

    context "with low oxygen" do
      it "returns false" do
        atmosphere.composition = { "N2" => 85.0, "O2" => 15.0 }  # Low O2
        expect(atmosphere.habitable?).to be false
      end
    end

    context "with high CO2" do
      it "returns false" do
        atmosphere.composition = { "N2" => 77.0, "O2" => 21.0, "CO2" => 2.0 }  # High CO2
        expect(atmosphere.habitable?).to be false
      end
    end

    context "with extreme temperature" do
      it "returns false for too cold" do
        atmosphere.temperature = 263.15  # -10°C
        expect(atmosphere.habitable?).to be false
      end

      it "returns false for too hot" do
        atmosphere.temperature = 323.15  # 50°C
        expect(atmosphere.habitable?).to be false
      end
    end
  end

  describe "AtmosphereConcern inclusion" do
    let(:atmosphere) { build(:enclosed_atmosphere, celestial_body: earth) }  # ✅ FIX

    it "includes AtmosphereConcern methods" do
      expect(atmosphere).to respond_to(:initialize_gases)
      expect(atmosphere).to respond_to(:add_gas)
      expect(atmosphere).to respond_to(:recalculate_gas_percentages)
    end
  end

  describe "JSON fields" do
    let(:atmosphere) { create(:enclosed_atmosphere, celestial_body: earth, temperature: 293.15, pressure: 101.325) }  # ✅ FIX

    it "initializes JSON fields with empty objects" do
      expect(atmosphere.composition).to eq({})
      expect(atmosphere.dust).to eq({})
      expect(atmosphere.gas_changes).to eq({})
      expect(atmosphere.base_values).to eq({})
      expect(atmosphere.temperature_data).to eq({})
    end

    it "allows storing data in JSON fields" do
      atmosphere.update!(
        composition: { "N2" => 78.08, "O2" => 20.95 },
        dust: { "particle_count" => 1000 },
        gas_changes: { "recent" => [] },
        base_values: { "original_pressure" => 101.325 },
        temperature_data: { "readings" => [] }
      )

      atmosphere.reload
      expect(atmosphere.composition["N2"]).to eq(78.08)
      expect(atmosphere.dust["particle_count"]).to eq(1000)
    end
  end

  describe "parent validation" do
    it "requires exactly one parent" do
      atmosphere = build(:enclosed_atmosphere, celestial_body: nil)
      atmosphere.craft_id = nil
      atmosphere.structure_id = nil
      
      expect(atmosphere).not_to be_valid
      expect(atmosphere.errors[:base]).to include("Atmosphere must belong to either a celestial_body, craft, or structure")
    end
    
    it "rejects multiple parents" do
      player = create(:player)
      settlement = create(:base_settlement, owner: player)
      craft = create(:base_craft, owner: player)
      structure = create(:base_structure, settlement: settlement, owner: player)
      
      atmosphere = build(:enclosed_atmosphere, celestial_body: earth)
      atmosphere.craft_id = craft.id
      atmosphere.structure_id = structure.id
      
      expect(atmosphere).not_to be_valid
      # ✅ FIX: Update to match the actual error message
      expect(atmosphere.errors[:base]).to include("Atmosphere can only belong to one parent (celestial_body, craft, or structure)")
    end
  end
end