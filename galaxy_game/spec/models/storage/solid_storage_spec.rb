# spec/models/storage/solid_storage_spec.rb
require 'rails_helper'

RSpec.describe Storage::SolidStorage, type: :model do
  let(:solid_storage) { Storage::SolidStorage.new(100) }

  it 'initializes with the correct type' do
    expect(solid_storage.item_type).to eq('Solid')
  end
end
