# Galaxy Game

**A SimEarth-inspired space colonization game featuring realistic manufacturing chains, AI-driven mission planning, and player-driven economics.**

Build settlements across the solar system and beyond. Process raw regolith into manufactured goods. Manage complex supply chains. Make critical decisions about terraforming alien worlds. Guide humanity's expansion through wormhole networks into the unknown.

---

## 🎮 Game Vision

### SimEarth Inspiration
- **Planetary Projection Systems**: Economic forecasting, resource flow visualization, terraforming progress tracking
- **Admin Tools**: System-wide monitoring and management interfaces
- **Emergent Complexity**: Simple rules creating complex, realistic outcomes

### Eve Online Inspiration  
- **Player-Driven Economy**: Contracts, insurance, logistics markets controlled by players
- **Mission Generation**: Procedural missions with pattern learning and AI adaptation
- **Corporation Mechanics**: Organizations, consortiums, reputation systems

### Realistic Science
Grounded in real physics, chemistry, and orbital mechanics while maintaining engaging gameplay.

---

## 🚀 Current Development Status

**Phase 3**: Integration & Restoration (Active)  
**Test Failures**: ~393 (down from 420) - Target: <50  
**Next Phase**: UI Enhancement (SimEarth admin panel + Eve mission builder)

**Recent Progress**:
- ✅ Shell construction system - 66/66 specs passing
- ✅ Consortium membership - 5/5 specs passing  
- ✅ Crater dome covering - 23/24 specs passing
- ✅ TradeService pricing logic - fixed factory issues and method implementations
- ✅ UnitAssemblyJob currency seeding - added GCC/USD currencies to test environment
- ✅ Orbital resupply cycle - updated craft type and mocking strategy
- 🔄 GameController singleton methods - moved method definitions before usage

📊 **[View Current Status](docs/development/active/CURRENT_STATUS.md)** | 🗺️ **[Development Roadmap](docs/development/planning/RESTORATION_AND_ENHANCEMENT_PLAN.md)**

---

## 📚 Documentation

### Quick Links
- **[Full Documentation Hub](docs/README.md)** - Complete documentation navigation
- **[Getting Started Guide](docs/developer/setup.md)** - Set up development environment
- **[Architecture Overview](docs/architecture/overview.md)** - System design and structure
- **[Game Mechanics](docs/gameplay/mechanics.md)** - Core gameplay systems

### For Developers
- **[Development Docs](docs/development/)** - Active work, planning, and reference guides
- **[Environment Rules](docs/development/reference/ENVIRONMENT_BOUNDARIES.md)** - Critical Docker/Git boundaries
- **[Testing Guide](docs/developer/ai_testing_framework.md)** - RSpec, integration tests, CI/CD

### For Players
- **[User Guide](docs/user/)** - How to play
- **[Terraforming Guide](docs/gameplay/terraforming.md)** - Planet transformation systems
- **[Trading System](#trading--logistics-system)** - Contracts, insurance, and logistics (see below)

---

## 🛠️ Tech Stack

- **Rails** 7.0.8.4
- **Ruby** 3.2
- **PostgreSQL** 16
- **Docker** (development environment)
- **RSpec** + Capybara + Selenium (testing)
- **SimpleCov** + CircleCI + Code Climate (quality control)

### Quick Start

```bash
# Clone repository
git clone https://github.com/yourusername/galaxyGame.git
cd galaxyGame

# Start development environment
docker-compose -f docker-compose.dev.yml up

# Run tests (in container)
docker-compose -f docker-compose.dev.yml exec web bundle exec rspec

# Access application
open http://localhost:3000
```

**Full setup instructions**: [docs/developer/setup.md](docs/developer/setup.md)

---

## 🏗️ Key Systems

### Manufacturing & Industry
- **ISRU Processing**: Regolith → Processed materials → Components → Structures
- **Component Production**: 3D printing, material processing, waste management
- **Construction**: Shells, domes, habitats, industrial facilities
- **[Manufacturing Chains Documentation](docs/architecture/SYSTEM_INDUSTRIAL_CHAINS.md)**

### Economics & Trade
- **Player Contracts**: Item exchange, courier services, auctions
- **Insurance System**: Risk management for logistics and trade
- **Organizations**: Corporations, consortiums, reputation systems
- **[Economic System Documentation](docs/architecture/financial_system.md)**

### Planetary Systems
- **Geosphere**: Geology, regolith composition, resource deposits
- **Hydrosphere**: Water systems, ice caps, subsurface oceans
- **Biosphere**: Terraforming, ecosystems, life support
- **[Planetary Systems Documentation](docs/architecture/)**

### AI & Automation
- **Mission Planning**: AI-driven expansion and resource optimization
- **Probe System**: Autonomous exploration and scouting
- **Pattern Learning**: AI learns from missions to improve future decisions
- **[AI Manager Documentation](docs/ai_manager/)**

---

## Trading & Logistics System

**Comprehensive player-driven trading inspired by EVE Online with integrated insurance for risk management.**

### Core Features

#### Player Contracts
- **Item Exchange**: Direct trades between players
- **Courier Services**: Transport contracts with insurance options
- **Auctions**: Player-created markets for goods
- **Location-Based**: Contracts available at specific stations/bases

#### Insurance & Risk Management
- **NPC Insurance Providers**: Three companies (Galactic Insurance Consortium, Luna Risk Management, Earth Transport Underwriters)
- **Risk-Based Pricing**: Premiums adjust based on route danger and contractor reputation
- **Coverage Tiers**: Basic (50%), Standard (75%), Premium (90%)
- **Claims Processing**: Automated assessment with manual review for disputes

#### Security & Trust
- **Collateral System**: Security deposits for contractors
- **Reputation Tracking**: Failed deliveries impact future opportunities
- **Escrow Services**: Secure fund/item holding during transactions
- **Player-First Logistics**: NPCs create player contracts first, fallback to automated delivery if no takers

### Example: Creating a Courier Contract

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

**Full API Documentation**: [docs/architecture/organizations_system.md](docs/architecture/organizations_system.md)

### Economic Impact
- **Player Agency**: Players control logistics market through competitive contracts
- **Market Dynamics**: Insurance companies compete on rates and coverage
- **Systemic Stability**: Insurance absorbs failures, preventing economic cascades

**Detailed Documentation**: [docs/architecture/financial_system.md](docs/architecture/financial_system.md)

---

## 🤝 Contributing

We welcome contributions! Current focus areas:

### Active Development (Phase 3)
- **Test Restoration**: Surgical fixes for ~398 failing specs
- **Code Quality**: Improving test coverage and documentation
- **Bug Fixes**: Addressing issues in manufacturing, financial, and settlement systems

### Upcoming (Phase 4)
- **UI Enhancement**: SimEarth-style admin panels and D3.js visualizations
- **Mission Builder**: Eve Online-inspired mission generation tools
- **System Projector**: Economic forecasting and resource flow tracking

### How to Contribute
1. Check **[Current Status](docs/development/active/CURRENT_STATUS.md)** for active work
2. Review **[Environment Boundaries](docs/development/reference/ENVIRONMENT_BOUNDARIES.md)** for critical development rules
3. Follow commit message format: `fix:`, `feat:`, `docs:`, `test:`
4. Update documentation with every code change
5. Submit PRs with passing tests

**Contribution Guidelines**: [docs/developer/README.md](docs/developer/README.md)

---

## 📖 Lore & Story

### The Premise
Humanity has discovered a network of wormholes enabling FTL travel. Your role: guide the expansion beyond Sol, establish settlements on alien worlds, develop manufacturing chains from raw regolith to complex structures, and make critical decisions about terraforming and resource allocation.

### Key Story Elements
- **Consortium Framework**: Competing factions and corporations
- **Crisis Mechanics**: Events and challenges driving narrative
- **AI Intelligence**: Autonomous systems learning from player decisions
- **Procedural Generation**: Unique alien worlds and challenges

**Full Storyline**: [docs/storyline/](docs/storyline/)

---

## 📊 Project Metrics

### Test Suite Health
- **Total Examples**: ~2,600
- **Current Failures**: ~398 (Phase 3 restoration in progress)
- **Target**: <50 failures before Phase 4
- **Coverage**: SimpleCov tracking (manufacturing pipeline fully tested)

### Development Activity
- **Active Branch**: `main`
- **Recent Commits**: Test restoration, manufacturing fixes, documentation reorganization
- **CI/CD**: CircleCI + Code Climate integration
- **Code Quality**: Monitored via Code Climate

---

## 📜 License

[License Type] - See LICENSE file for details

---

## 🔗 Links

- **Documentation**: [docs/README.md](docs/README.md)
- **GitHub Issues**: [Issue Tracker](#)
- **Project Board**: [Development Roadmap](#)
- **Live Demo**: [Coming Soon]

---

**Last Updated**: January 16, 2026  
**Version**: Development (Phase 3 - Test Restoration) 