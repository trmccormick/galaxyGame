# Galaxy Game

**A SimEarth-inspired space colonization game featuring realistic manufacturing chains, AI-driven mission planning, and player-driven economics.**

Build settlements across the solar system and beyond. Process raw regolith into manufactured goods. Manage complex supply chains. Make critical decisions about terraforming alien worlds. Guide humanity's expansion through wormhole networks into the unknown.

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
- ✅ Protoplanet classification - implemented for large asteroids (Vesta, Psyche)
- ✅ Terrain generation fixes - Titan GeoTIFF usage, protoplanet support
- 🔄 GameController singleton methods - moved method definitions before usage

📊 **[View Current Status](docs/development/active/CURRENT_STATUS.md)** | 🗺️ **[Development Roadmap](docs/development/planning/RESTORATION_AND_ENHANCEMENT_PLAN.md)**

---

## 🛠️ Tech Stack & Environment

- **Backend:** Rails 7.0.8.4 | Ruby 3.2 | PostgreSQL 16
- **Environment:** Docker-managed development environment
- **Testing Engine:** RSpec + Capybara + Selenium
- **Quality Control:** SimpleCov + CircleCI + Code Climate

### 🚀 Quick Start

```bash
# Clone repository
git clone [https://github.com/yourusername/galaxyGame.git](https://github.com/yourusername/galaxyGame.git)
cd galaxyGame

# Start development environment
docker-compose -f docker-compose.dev.yml up

# Run tests (in container)
docker-compose -f docker-compose.dev.yml exec web bundle exec rspec

# Access application
open http://localhost:3000