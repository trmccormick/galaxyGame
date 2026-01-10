# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Biology::LifeFormParent, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:parent).class_name('Biology::BaseLifeForm') }
    it { is_expected.to belong_to(:child).class_name('Biology::BaseLifeForm') }
  end

  describe 'table name' do
    it 'uses the correct table name' do
      expect(described_class.table_name).to eq('biology_life_form_parents')
    end
  end
end
