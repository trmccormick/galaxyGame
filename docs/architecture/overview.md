# Galaxy Game Architecture Overview

## System Architecture

Galaxy Game is a Rails-based space simulation game that models planetary colonization, resource management, and interplanetary logistics.

### Core Components

#### 🌍 Planetary Systems
- **Celestial Bodies**: Planets, moons, asteroids with realistic physics and compositions
- **Spheres**: Atmosphere, hydrosphere, geosphere, biosphere layers with independent simulation
  - [Hydrosphere System](hydrosphere_system.md): Generic liquid modeling for diverse planetary environments
  - [Geosphere System](geosphere_system.md): Generic solid body modeling with geological processes
- **Terraforming**: Multi-stage planetary modification with realistic constraints

#### 🚀 Space Infrastructure
- **Cyclers**: Mobile space stations for interplanetary transport and construction
  - [Cycler System](cycler_system.md): Mission configurations and equipment transfer
  - [Foundry Logic & Lunar Elevator](foundry_logic_and_lunar_elevator.md): Interplanetary industrial symbiosis
- **Stations**: Orbital platforms for processing, manufacturing, and crew habitation
- **Depots**: Automated cargo facilities for resource storage and transfer

#### 🤖 AI Manager
- **Mission Planning**: Automated generation of colonization missions
- **Resource Allocation**: Dynamic distribution of equipment and personnel
- **Pattern Learning**: AI learns from successful mission templates

#### 📊 Economic Engine
- **Market System**: Dynamic pricing based on supply/demand
- **Resource Chains**: Multi-stage processing from raw materials to finished products
- **Logistics**: Interplanetary trade and transportation networks

### Data Architecture

#### JSON Configuration Files
- **Blueprints**: Equipment and structure definitions
- **Operational Data**: Runtime configurations for specific installations
- **Mission Profiles**: Pre-defined colonization patterns

#### Database Schema
- **Celestial Bodies**: Hierarchical planet/moon relationships
- **Equipment**: Modular units with attachment points
- **Missions**: Complex multi-phase operations with dependencies

### Technology Stack

- **Backend**: Ruby on Rails 7.0
- **Database**: PostgreSQL with PostGIS for spatial data
- **Frontend**: Vanilla JavaScript with custom UI framework
- **Testing**: RSpec, Capybara, Selenium
- **Deployment**: Docker containers with docker-compose

### Development Workflow

1. **Planning**: Mission profiles define colonization strategies
2. **Implementation**: Blueprints and operational data configure equipment
3. **Simulation**: TerraSim models planetary changes over time
4. **Testing**: Comprehensive test suite ensures system stability
5. **Deployment**: Automated builds and containerized deployment

---

*For detailed documentation on specific systems, see the sections below.*