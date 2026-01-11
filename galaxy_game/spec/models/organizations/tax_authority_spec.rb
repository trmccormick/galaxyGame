require 'rails_helper'

RSpec.describe Organizations::TaxAuthority, type: :model do
  # Ensure the necessary base organization factory is available
  # let(:tax_authority) { Organizations::TaxAuthority.instance } 
  
  # Note: TaxAuthority.instance creates and returns the object

  describe '.instance' do
    it 'creates the Tax Authority if it does not exist' do
      # Ensure no instance exists initially (relying on database cleaner)
      Organizations::TaxAuthority.destroy_all 
      
      expect {
        Organizations::TaxAuthority.instance
      }.to change(Organizations::TaxAuthority, :count).by(1)
    end

    it 'always returns the same single instance' do
      instance1 = Organizations::TaxAuthority.instance
      instance2 = Organizations::TaxAuthority.instance
      
      expect(instance1).to eq(instance2)
      expect(Organizations::TaxAuthority.count).to eq(1)
    end

    it 'initializes with the correct identifier and name' do
      authority = Organizations::TaxAuthority.instance
      expect(authority.name).to eq('Galactic Commerce Commission Tax Authority')
      expect(authority.identifier).to eq('GCC-TAX')
    end
  end
  
  describe '#tax_rate' do
    it 'always returns 0.0, as the Tax Authority does not pay tax' do
      authority = Organizations::TaxAuthority.instance
      expect(authority.tax_rate).to eq(0.0)
    end
  end
end