# spec/models/storage/gas_storage_spec.rb
require 'rails_helper'

RSpec.describe Storage::GasStorage, type: :model do
  let(:gas_storage) { Storage::GasStorage.new(100) }

  it 'initializes with the correct type' do
    expect(gas_storage.item_type).to eq('Gas')
  end
end
