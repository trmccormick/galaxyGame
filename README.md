# galaxyGame
Rails Game similar to SimEarth

## Versions
- Rails 7.0.8.4
- Ruby 3.2
- Postgress 16

## Testing and Quality Control 
The test suite includes rspec, capybara, selnium, simplecov, CircleCI, and code climate. 
Javascript is difficult to test by iteself.  To run tests locally uncomment the selenium docker container and adjust capybara setups. 
`RAILS_ENV=test bundle exec rspec` this helps to ensure that all gems are loaded appropriately and you do not get the `shoulda error`.  

### Troubleshooting
Using Chatgpt to generate some of this code based on the original java version.

## Trading & Logistics System

### Overview
The game features a comprehensive player-driven trading and logistics system inspired by EVE Online, with integrated insurance for risk management.

### Key Components

#### 1. Player Contracts
- **Item Exchange**: Direct item-for-item trades between players
- **Courier Contracts**: Transport services with insurance options
- **Auction System**: Player-created auctions for goods
- **Location-Based**: Contracts only available at specific stations/bases

#### 2. Insurance System
- **NPC Insurance Corporations**: Three pre-seeded insurance companies
  - Galactic Insurance Consortium (Luna-based)
  - Luna Risk Management Corp (Luna-based)
  - Earth Transport Underwriters (Earth-based)
- **Risk-Based Pricing**: Premiums adjust based on route risk and contractor reliability
- **Coverage Tiers**: Basic (50%), Standard (75%), Premium (90%)
- **Claim Processing**: Automated assessment with manual review for high-risk claims

#### 3. Security Mechanisms
- **Collateral Requirements**: Contractors must post security deposits
- **Insurance Coverage**: Optional protection against cargo loss
- **Reputation System**: Failed deliveries impact future contract access
- **Escrow System**: Secure fund/item holding during transactions

#### 4. Player-First Logistics
- **NPC Contract Creation**: When NPCs need goods moved, player contracts are created first
- **Fallback System**: If no players accept, automated NPC logistics handle delivery
- **Variable Transport Costs**: Cycler network vs. player contract pricing
- **Same-Body Transfers**: Surface logistics for settlements on the same celestial body

### Usage Examples

#### Creating a Courier Contract
```ruby
# NPC creates player-visible contract
contract_data = {
  issuer: npc_settlement,
  contract_type: :courier,
  location: pickup_station,
  requirements: {
    pickup_location: "Luna Base",
    delivery_location: "Earth Station",
    cargo: { material: "titanium", quantity: 1000 }
  },
  reward: { credits: 5000 },
  collateral: { amount: 2500, type: 'gcc' }
}

result = Logistics::PlayerContractService.create_logistics_contract(contract_data)
```

#### Purchasing Insurance
```ruby
# Player purchases insurance for contract
insurance_options = TradeService.get_insurance_options(contract)
premium = TradeService.calculate_insurance_premium(contract.value, :standard)

# Accept contract with insurance
TradeService.accept_contract(contract, player, { insurer_id: insurer.id, tier: :standard })
```

#### Processing Contract Completion/Failure
```ruby
# Successful delivery
TradeService.complete_contract(contract)

# Failed delivery (cargo lost)
TradeService.fail_contract(contract, {
  type: 'cargo_lost',
  loss_amount: contract.value,
  cargo_recovered: false
})
```

### Economic Impact
- **Player Agency**: Players control logistics market, not just automated systems
- **Risk/Reward Balance**: High-risk contracts offer better rewards but require insurance
- **Market Dynamics**: Insurance companies compete on rates and coverage
- **Systemic Stability**: Insurance absorbs logistics failures, preventing economic cascades

### Future Enhancements
- **Player Insurance Corporations**: Players can create and manage insurance companies
- **Reinsurance Market**: Insurance companies can hedge their own risks
- **Contract Arbitration**: Dispute resolution system for contested deliveries
- **Advanced Risk Modeling**: Machine learning-based premium calculation 