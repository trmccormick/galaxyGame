FactoryBot.define do
  factory :import_request, class: 'Logistics::ImportRequest' do
    association :settlement, factory: :base_settlement
    resource { 'water' }
    quantity_needed { 100 }
    cost_analysis { { local_cost: 10, import_cost: 20, recommendation: :import } }
    status { :created }
    tier { :survival }
    priority { :normal }
    category { :other }
    manifest { nil }
  end
end
