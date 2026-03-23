
# Galaxy Game

**The Ultimate Multi-Layer Space Colonization Simulator**  
A high-fidelity hybrid of SimEarth, FreeCiv/Civ4, SimCity, and EVE Online.

Galaxy Game is a comprehensive industrial and planetary simulation built on Ruby on Rails. It scales from the microscopic chemical composition of regolith to the macroscopic expansion of interstellar empires.

---

## 🚀 Development Status

**Phase 4 (Expansion)**

**Current Focus:** Surface Layer MVP & Industrial Loop Balancing.

**Test Suite Health:** <82 Failures (Restoration "Grinder" phase terminated).

**Backlog:** 178 Active Tasks identified for the current sprint.

**Key Achievement:** Transitioned to a strictly JSON-driven blueprint system for unit architecture.

📊 **[View Current Status](docs/CURRENT_STATUS.md)** | 🗺️ **[Development Roadmap](docs/agent/planning/RESTORATION_AND_ENHANCEMENT_PLAN.md)**

---

## 🎮 The Four-Layer Vision
The simulation architecture is divided into four distinct operational layers:

1. **Macro: Planetary Simulation (SimEarth)**
  - Focus: Global habitability, 100+ year terraforming projections, and atmospheric chemistry.
  - Digital Twin Service: A high-speed "What If?" sandbox for projecting deep-time planetary outcomes before resource commitment.

2. **Meso: Grand Strategy & Expansion (Civ4 / FreeCiv)**
  - Focus: Settlement placement, unit deployment, and territorial expansion.
  - Current MVP: Deploying heavy lift craft to surface tiles (e.g., lava tube entrances) for harvesting and initial base setup.

3. **Micro: Industrial Construction (SimCity / TerrainForge)**
  - Focus: Detailed settlement simulation, worldhouse enclosures, and infrastructure.
  - TerrainForge: The "X-ray" layer for monitoring active construction events, managing I-beams, and panel configurations.

4. **Economic: Industrial Logistics (EVE Online)**
  - Focus: Player-driven markets and "Market vs. Build" industrial logic.
  - Tax Structure: SCC Surcharge (0.5%), Broker Fee (0.3%), Sales Tax (3.37%).

---

## 📚 Documentation Map
The `docs/` directory is governed by the Documentation Strategist to prevent fragmentation.

## ⚖️ Project Governance
- **GUARDRAILS.md**: Mandatory rules for code, documentation, and agent behavior.
- **CURRENT_STATUS.md**: Real-time tracking of active failures and sprint progress.
- **GLOSSARY_SYSTEM_MECHANICS.md**: Unified terminology for all four simulation layers.

## 🏗️ Architecture & Engineering
- `architecture/`: High-level designs including the AI Manager and Planetary Patterns.
- `economics/`: Market mechanics, tax structures, and PLEX trading logic.
- `systems/`: Technical deep dives into ISRU, Shell Printing, and Wormholes.

## 👨‍💻 Developer Resources
- `docs/agent/`: Clean-root directory for active implementation agents.
- `WORKFLOW_README.md`: Documentation process overview and core deliverable standards.


---

## 🎮 Game Vision

### SimEarth Inspiration
- **Planetary Simulation**: Test terraforming scenarios with accelerated time (100-year projections in minutes)
- **Admin Control**: Manual mission design teaching AI patterns for autonomous deployment
- **Economic Projection**: Resource flow visualization showing GCC movement across solar system
- **Emergent Complexity**: Simple controls creating realistic planetary evolution and economic outcomes

### Eve Online Inspiration  
- **Player-Driven Economy**: Contracts, insurance, logistics markets controlled by players
- **Mission Generation**: Procedural missions with pattern learning and AI adaptation
- **Corporation Mechanics**: Organizations, consortiums, reputation systems

### Realistic Science
Grounded in real physics, chemistry, and orbital mechanics while maintaining engaging gameplay.

**Deep Dive**: [SimEarth Admin Vision](docs/architecture/SIMEARTH_ADMIN_VISION.md) - Comprehensive guide to planetary simulation, mission control, and AI pattern learning

---


## 🚀 Development Status

**Phase 4 (Expansion)**

**Current Focus:** Surface Layer MVP & Industrial Loop Balancing

**Test Suite Health:** 3941 examples, 87 failures, 22 pending (as of last run)

**Backlog:** 178 Active Tasks identified for the current sprint

**Key Achievement:** Transitioned to a strictly JSON-driven blueprint system for unit architecture

📊 **[View Current Status](docs/agent/CURRENT_STATUS.md)** | 🗺️ **[Development Roadmap](docs/agent/planning/RESTORATION_AND_ENHANCEMENT_PLAN.md)**
## 🎮 The Four-Layer Vision
The simulation architecture is divided into four distinct operational layers:

1. **Macro: Planetary Simulation (SimEarth)**
  - Focus: Global habitability, 100+ year terraforming projections, and atmospheric chemistry.
  - Digital Twin Service: A high-speed "What If?" sandbox for projecting deep-time planetary outcomes before resource commitment.

2. **Meso: Grand Strategy & Expansion (Civ4 / FreeCiv)**
  - Focus: Settlement placement, unit deployment, and territorial expansion.
  - Current MVP: Deploying heavy lift craft to surface tiles (e.g., lava tube entrances) for harvesting and initial base setup.

3. **Micro: Industrial Construction (SimCity / TerrainForge)**
  - Focus: Detailed settlement simulation, worldhouse enclosures, and infrastructure.
  - TerrainForge: The "X-ray" layer for monitoring active construction events, managing I-beams, and panel configurations.

4. **Economic: Industrial Logistics (EVE Online)**
  - Focus: Player-driven markets and "Market vs. Build" industrial logic.
  - Tax Structure: SCC Surcharge (0.5%), Broker Fee (0.3%), Sales Tax (3.37%).

## 📚 Documentation Map
The docs/ directory is governed by the Documentation Strategist to prevent fragmentation.

## ⚖️ Project Governance
- **GUARDRAILS.md**: Mandatory rules for code, documentation, and agent behavior.
- **CURRENT_STATUS.md**: Real-time tracking of active failures and sprint progress.
- **GLOSSARY_SYSTEM_MECHANICS.md**: Unified terminology for all four simulation layers.

## 🏗️ Architecture & Engineering
- **architecture/**: High-level designs including the AI Manager and Planetary Patterns.
- **economics/**: Market mechanics, tax structures, and PLEX trading logic.
- **systems/**: Technical deep dives into ISRU, Shell Printing, and Wormholes.

## 👨‍💻 Developer Resources
- **docs/agent/**: Clean-root directory for active implementation agents.
- **WORKFLOW_README.md**: Documentation process overview and core deliverable standards.


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
- **Minor Bodies**: Asteroids, protoplanets, dwarf planets classification
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
**Last Updated**: March 22, 2026
**Project Lead**: Tracy McCormick
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
- **Test Restoration**: Surgical fixes for ~393 failing specs
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


### Data-Driven Unit Architecture & JSON Migration
- **BiogasUnit Migration**: The `biogas_generator` and `biogas_unit` have been migrated to a JSON-driven BaseUnit architecture. All legacy Ruby models have been removed in favor of template-compliant JSON blueprints and operational data.
- **JSON Data Protocol**: JSON blueprint and operational data files (e.g., `biogas_generator_bp.json`, `biogas_generator_data.json`) are **NOT** committed to GitHub. Contributors must follow the documented workflow for local creation and validation.
- **Standards & Workflow**: See [docs/developer/JSON_DATA_GUIDE.md](docs/developer/JSON_DATA_GUIDE.md) for naming conventions, required fields, and validation steps for all unit JSON data.

### Development Workflow
- **Git Practices**: Be selective with staging - avoid `git add .` as it can interfere with other developers' work
- **File Staging**: Use `git add <specific-file>` to stage only the files you're responsible for
- **Collaboration**: Check `git status` first to see what files have changed, then selectively add only your changes
- **Testing**: Run full test suite before committing to ensure no regressions

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
- **Current Failures**: ~393 (Phase 3 restoration in progress)
- **Target**: <50 failures before Phase 4
- **Coverage**: SimpleCov tracking (manufacturing pipeline fully tested)

### Development Activity
- **Active Branch**: `main`
- **Recent Commits**: Test restoration, manufacturing fixes, protoplanet implementation, terrain generation fixes, documentation reorganization
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

**Last Updated**: March 22, 2026  
**Project Lead**: Tracy McCormick
**Version**: Development (Phase 4 - Expansion)