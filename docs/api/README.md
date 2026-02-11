# Galaxy Game API Reference

## Overview

Galaxy Game provides RESTful APIs for administrative monitoring, AI management, and system control. All admin APIs require authentication and are intended for system administrators and developers.

## Authentication

**Method**: Session-based authentication (Rails default)
**Access**: Admin namespace requires admin user login
**Base URL**: `/admin/`

## Celestial Bodies API

### List Celestial Bodies
**Endpoint**: `GET /admin/celestial_bodies`
**Purpose**: Get paginated list of all celestial bodies

**Response**:
```json
{
  "celestial_bodies": [
    {
      "id": 1,
      "name": "Earth",
      "type": "terrestrial_planet",
      "body_category": "terrestrial_planet",
      "created_at": "2026-01-15T10:00:00Z"
    }
  ],
  "total_bodies": 15,
  "bodies_by_type": {
    "terrestrial_planet": [...],
    "gas_giant": [...]
  },
  "habitable_count": 3
}
```

### Get Sphere Data
**Endpoint**: `GET /admin/celestial_bodies/:id/sphere_data`
**Purpose**: Real-time sphere data for monitoring

**Response**:
```json
{
  "atmosphere": {
    "pressure": 1.013,
    "temperature": 288.15,
    "composition": {
      "N2": 78.09,
      "O2": 20.95,
      "Ar": 0.93
    }
  },
  "hydrosphere": {
    "water_coverage": 71.0,
    "total_liquid_mass": 1.35e18,
    "average_depth": 3688
  },
  "geosphere": {
    "terrain_map": {
      "grid": [[...]],
      "width": 180,
      "height": 90
    }
  },
  "biosphere": {
    "biodiversity_index": 0.85,
    "habitable_ratio": 0.92
  },
  "planet_info": {
    "id": 1,
    "name": "Earth",
    "radius": 6371000,
    "gravity": 9.81
  },
  "terrain_data": {
    "grid": [[...]],
    "biomes": ["ocean", "grassland", ...]
  }
}
```

### Get Mission Log
**Endpoint**: `GET /admin/celestial_bodies/:id/mission_log`
**Purpose**: AI mission activity log

**Response**:
```json
{
  "missions": [
    {
      "id": 1,
      "type": "Resource Extraction",
      "status": "active",
      "start_time": "2026-02-11T14:30:00Z",
      "target_body": "Mars",
      "progress": 45,
      "messages": [
        {
          "time": "2026-02-11T14:30:00Z",
          "level": "info",
          "text": "Mission initialized"
        }
      ]
    }
  ],
  "total_missions": 1,
  "active_missions": 1
}
```

### Run AI Test
**Endpoint**: `POST /admin/celestial_bodies/:id/run_ai_test`
**Purpose**: Trigger AI Manager test mission

**Parameters**:
```json
{
  "test_type": "resource_extraction"
}
```

**Available Test Types**:
- `resource_extraction`
- `base_construction`
- `isru_pipeline`
- `gcc_bootstrap`

**Response**:
```json
{
  "success": true,
  "test_type": "resource_extraction",
  "message": "Resource extraction test completed successfully",
  "results": {
    "sites_found": 12,
    "optimal_location": {
      "latitude": 45.2,
      "longitude": -122.3
    }
  }
}
```

## AI Manager API

### Get Missions
**Endpoint**: `GET /admin/ai_manager/missions`
**Purpose**: List all AI missions

**Response**:
```json
{
  "missions": [
    {
      "id": 1,
      "type": "Resource Extraction",
      "status": "active",
      "target_body": "Mars",
      "progress": 45
    }
  ]
}
```

### Get Mission Details
**Endpoint**: `GET /admin/ai_manager/missions/:id`
**Purpose**: Detailed mission information

### Advance Mission Phase
**Endpoint**: `POST /admin/ai_manager/missions/:id/advance_phase`
**Purpose**: Move mission to next phase

### Reset Mission
**Endpoint**: `POST /admin/ai_manager/missions/:id/reset`
**Purpose**: Reset mission to initial state

### Get AI Planner
**Endpoint**: `GET /admin/ai_manager/planner`
**Purpose**: Access AI mission planning interface

### Export Plan
**Endpoint**: `POST /admin/ai_manager/export_plan`
**Purpose**: Export AI-generated mission plan

**Parameters**:
```json
{
  "format": "json",
  "include_details": true
}
```

### Get AI Decisions
**Endpoint**: `GET /admin/ai_manager/decisions`
**Purpose**: View AI decision history

### Get AI Patterns
**Endpoint**: `GET /admin/ai_manager/patterns`
**Purpose**: View learned AI patterns

### Get AI Performance
**Endpoint**: `GET /admin/ai_manager/performance`
**Purpose**: AI system performance metrics

## Map Studio API

### List Maps
**Endpoint**: `GET /admin/map_studio`
**Purpose**: Browse available maps for analysis

### Generate Map
**Endpoint**: `POST /admin/map_studio/generate_map`
**Purpose**: Generate new planetary map

**Parameters**:
```json
{
  "celestial_body_id": 1,
  "map_type": "terrain",
  "resolution": "high"
}
```

### Apply Map
**Endpoint**: `POST /admin/map_studio/apply_map/:id`
**Purpose**: Apply generated map to celestial body

### Analyze Map
**Endpoint**: `GET /admin/map_studio/analyze/:id`
**Purpose**: Get detailed map analysis

## Solar Systems API

### List Solar Systems
**Endpoint**: `GET /admin/solar_systems`
**Purpose**: Get all solar systems

### Get Solar System Details
**Endpoint**: `GET /admin/solar_systems/:id`
**Purpose**: Detailed solar system information

## Galaxies API

### List Galaxies
**Endpoint**: `GET /admin/galaxies`
**Purpose**: Get all galaxies

### Get Galaxy Details
**Endpoint**: `GET /admin/galaxies/:id`
**Purpose**: Detailed galaxy information

## Organizations API

### Get Operations
**Endpoint**: `GET /admin/organizations/:id/operations`
**Purpose**: Organization operational data

### Get Contracts
**Endpoint**: `GET /admin/organizations/contracts`
**Purpose**: Available contracts

## Settlements API

### List Settlements
**Endpoint**: `GET /admin/settlements`
**Purpose**: Get all settlements

### Get Settlement Details
**Endpoint**: `GET /admin/settlements/:id/details`
**Purpose**: Detailed settlement information

### Get Construction Jobs
**Endpoint**: `GET /admin/settlements/construction_jobs`
**Purpose**: Active construction projects

## Resources API

### List Resources
**Endpoint**: `GET /admin/resources`
**Purpose**: System resource overview

### Get Resource Flows
**Endpoint**: `GET /admin/resources/flows`
**Purpose**: Resource flow visualization

### Get Supply Chains
**Endpoint**: `GET /admin/resources/supply_chains`
**Purpose**: Supply chain analysis

### Get Market Data
**Endpoint**: `GET /admin/resources/market`
**Purpose**: Market prices and trends

## Simulation API

### Get Simulation Status
**Endpoint**: `GET /admin/simulation`
**Purpose**: Current simulation state

### Run Simulation
**Endpoint**: `POST /admin/simulation/run/:id`
**Purpose**: Run specific simulation

### Run All Simulations
**Endpoint**: `POST /admin/simulation/run_all`
**Purpose**: Run all simulations

### Get Spheres Data
**Endpoint**: `GET /admin/simulation/spheres`
**Purpose**: Sphere simulation data

### Get Time Control
**Endpoint**: `GET /admin/simulation/time_control`
**Purpose**: Simulation time controls

### Get Testing Interface
**Endpoint**: `GET /admin/simulation/testing`
**Purpose**: Simulation testing tools

## Error Handling

All API endpoints return standard HTTP status codes:

- `200`: Success
- `400`: Bad Request (invalid parameters)
- `401`: Unauthorized (authentication required)
- `403`: Forbidden (insufficient permissions)
- `404`: Not Found
- `422`: Unprocessable Entity (validation errors)
- `500`: Internal Server Error

Error responses include:
```json
{
  "error": "Error message",
  "details": "Additional error information"
}
```

## Rate Limiting

Admin APIs are rate limited to prevent abuse:
- 100 requests per minute per IP
- 1000 requests per hour per IP

## Versioning

Current API version: v1
All endpoints are prefixed with `/admin/`

---

**Last Updated**: February 11, 2026
**API Version**: v1.0