# spec/models/concerns/transactable_spec.rb
require 'rails_helper'

RSpec.describe Transactable, type: :model do
  let(:player) { create(:player) }
  # let(:corporation) { create(:corporation) }
  # let(:organization) { create(:organization) }

  it 'ensures player has an associated account' do
    expect(player.account).to be_present
  end

  # it 'ensures corporation has an associated account' do
  #   expect(corporation.account).to be_present
  # end

  # it 'ensures organization has an associated account' do
  #   expect(organization.account).to be_present
  # end
end
