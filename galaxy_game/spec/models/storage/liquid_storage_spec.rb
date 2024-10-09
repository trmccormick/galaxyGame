# spec/models/storage/liquid_storage_spec.rb
require 'rails_helper'

RSpec.describe Storage::LiquidStorage, type: :model do
  let(:liquid_storage) { Storage::LiquidStorage.new(100) }

  it 'initializes with the correct type' do
    expect(liquid_storage.item_type).to eq('Liquid')
  end
end
