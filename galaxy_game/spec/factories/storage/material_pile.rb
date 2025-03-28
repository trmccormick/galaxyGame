FactoryBot.define do
    factory :material_pile, class: 'Storage::MaterialPile' do
      surface_storage { association :surface_storage }
      material_type { 'processed_lunar_regolith' }
      amount { 100 }
    end
end