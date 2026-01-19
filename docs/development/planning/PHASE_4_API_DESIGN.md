# Phase 4 API Design: Digital Twin Sandbox Endpoints
**Date**: January 19, 2026
**Status**: Design Phase (Pre-implementation)

## Overview
RESTful API endpoints for the SimEarth Digital Twin Sandbox, enabling accelerated planetary simulations and interactive admin controls.

## Core Endpoints

### Digital Twin Management

#### `POST /admin/digital_twins`
**Purpose**: Create a new digital twin by cloning celestial body data
**Request Body**:
```json
{
  "celestial_body_id": 123,
  "name": "Mars Terraform Simulation 2026-01-19",
  "simulation_parameters": {
    "accelerated_time": true,
    "time_multiplier": 100,  // 1 day = 100 years
    "preserve_live_data": true
  }
}
```
**Response**: DigitalTwin resource with transient ID
**Status**: 201 Created

#### `GET /admin/digital_twins/:id`
**Purpose**: Retrieve digital twin status and current state
**Response**:
```json
{
  "id": "transient_123",
  "name": "Mars Terraform Simulation 2026-01-19",
  "celestial_body_id": 123,
  "status": "ready",
  "created_at": "2026-01-19T10:00:00Z",
  "atmosphere": { /* cloned data */ },
  "hydrosphere": { /* cloned data */ },
  "biosphere": { /* cloned data */ },
  "geosphere": { /* cloned data */ }
}
```

#### `DELETE /admin/digital_twins/:id`
**Purpose**: Clean up transient digital twin data
**Response**: 204 No Content

### Simulation Control

#### `POST /admin/digital_twins/:id/simulate`
**Purpose**: Run accelerated simulation on digital twin
**Request Body**:
```json
{
  "pattern": "mars-terraform",
  "duration_years": 100,
  "parameters": {
    "budget_multiplier": 1.5,
    "tech_level": "current",
    "priority": "balanced"
  }
}
```
**Response**: Simulation job status
**Status**: 202 Accepted (async processing)

#### `GET /admin/digital_twins/:id/simulate/:job_id`
**Purpose**: Check simulation progress
**Response**:
```json
{
  "job_id": "sim_456",
  "status": "running",
  "progress": 0.67,
  "current_year": 67,
  "estimated_completion": "2026-01-19T10:05:00Z",
  "results": { /* partial results if available */ }
}
```

#### `GET /admin/digital_twins/:id/simulate/:job_id/results`
**Purpose**: Retrieve complete simulation results
**Response**:
```json
{
  "pattern": "mars-terraform",
  "duration_years": 100,
  "start_state": { /* initial conditions */ },
  "end_state": { /* final conditions */ },
  "key_events": [
    {
      "year": 15,
      "event": "oxygen_threshold_reached",
      "description": "Atmospheric O2 reached 0.1% - photosynthesis established"
    }
  ],
  "resource_consumption": { /* GCC and material usage */ },
  "success_metrics": {
    "habitability_score": 0.78,
    "timeline_efficiency": 0.92,
    "resource_efficiency": 0.85
  }
}
```

### Manifest Export

#### `POST /admin/digital_twins/:id/manifest`
**Purpose**: Export simulation results as deployable manifest
**Request Body**:
```json
{
  "simulation_job_id": "sim_456",
  "manifest_version": "v1.1",
  "optimization_level": "balanced"
}
```
**Response**: Downloadable manifest_v1.1.json
**Content-Type**: application/json
**Disposition**: attachment; filename="mars_terraform_manifest_v1.1.json"

### Resource Flow Visualization

#### `GET /admin/resources/flows/:solar_system_id`
**Purpose**: Get resource flow data for D3.js visualization
**Query Parameters**:
- `start_date`: ISO date string
- `end_date`: ISO date string
- `resource_types`: comma-separated list
**Response**:
```json
{
  "nodes": [
    {
      "id": "earth",
      "name": "Earth",
      "type": "source",
      "total_throughput": 15000000  // kg/month
    },
    {
      "id": "mars_colony",
      "name": "Mars Colony",
      "type": "settlement",
      "total_throughput": 8500000
    }
  ],
  "links": [
    {
      "source": "earth",
      "target": "mars_colony",
      "value": 15000,
      "resource": "H2O",
      "gcc_value": 1200000,
      "route_efficiency": 0.94
    }
  ]
}
```

## Mission Profile Builder

#### `GET /admin/missions/templates`
**Purpose**: List available mission profile templates
**Response**: Array of template metadata

#### `POST /admin/missions`
**Purpose**: Create new mission profile from builder UI
**Request Body**: Complete mission profile JSON
**Response**: Created mission profile resource

#### `POST /admin/missions/validate`
**Purpose**: Validate mission profile against schema
**Request Body**: Mission profile JSON
**Response**: Validation results with errors/warnings

## Error Handling

All endpoints return standard HTTP status codes:
- `400 Bad Request`: Invalid parameters
- `404 Not Found`: Resource doesn't exist
- `409 Conflict`: Digital twin operation in progress
- `422 Unprocessable Entity`: Validation errors
- `500 Internal Server Error`: System errors

Error response format:
```json
{
  "error": "SimulationFailed",
  "message": "TerraSim service unavailable",
  "details": { /* additional context */ }
}
```

## Security Considerations

- All endpoints require admin authentication
- Digital twin operations are isolated from live data
- Rate limiting on simulation endpoints
- Audit logging for all manifest exports

## Implementation Notes

- Digital twin data stored in Redis/memory for performance
- Simulation jobs processed asynchronously via ActiveJob
- Results cached for UI responsiveness
- WebSocket support for real-time progress updates (future enhancement)</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/development/planning/PHASE_4_API_DESIGN.md