# db/seeds/insurance_corporations.rb
require_relative '../../app/services/insurance/insurance_market_service'

puts "Seeding NPC Insurance Corporations..."

Insurance::InsuranceMarketService.seed_npc_insurers

puts "Insurance corporations seeded successfully!"