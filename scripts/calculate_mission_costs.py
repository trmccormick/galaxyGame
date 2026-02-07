#!/usr/bin/env python3
"""
Cost Calculation Script for Solar System Infrastructure Missions

This script calculates realistic costs for mission manifests based on:
1. Equipment requirements from mission manifests
2. Material and item costs from the game database
3. Scaling factors for space operations
4. Labor and overhead costs

Usage: python3 calculate_mission_costs.py [mission_manifest.json]
"""

import json
import sys
import os
from pathlib import Path

class MissionCostCalculator:
    def __init__(self, data_dir="data/json-data"):
        self.data_dir = Path(data_dir)
        self.cost_mappings = {}
        self.material_costs = {}
        self.item_values = {}
        self.load_cost_data()

    def load_cost_data(self):
        """Load cost mappings, material costs, and item values"""
        # Load cost calculation system
        cost_file = self.data_dir / "cost_calculation_system.json"
        if cost_file.exists():
            with open(cost_file, 'r') as f:
                cost_data = json.load(f)
                self.cost_mappings = cost_data.get('equipment_cost_mappings', {})
                self.phase_mappings = cost_data.get('phase_equipment_mappings', {})

        # Load material costs
        materials_dir = self.data_dir / "resources/materials"
        for root, dirs, files in os.walk(materials_dir):
            for file in files:
                if file.endswith('.json'):
                    try:
                        with open(os.path.join(root, file), 'r') as f:
                            material = json.load(f)
                            if 'cost_data' in material and 'purchase_cost' in material['cost_data']:
                                cost = material['cost_data']['purchase_cost']['amount']
                                self.material_costs[material.get('id', file.replace('.json', ''))] = cost
                    except:
                        continue

        # Load item values
        items_dir = self.data_dir / "items"
        for root, dirs, files in os.walk(items_dir):
            for file in files:
                if file.endswith('.json'):
                    try:
                        with open(os.path.join(root, file), 'r') as f:
                            item = json.load(f)
                            if 'game_properties' in item and 'value' in item['game_properties']:
                                value = item['game_properties']['value']
                                self.item_values[item.get('id', file.replace('.json', ''))] = value
                    except:
                        continue

    def calculate_equipment_cost(self, equipment_list, environment_factors=None):
        """Calculate cost for a list of equipment items"""
        if environment_factors is None:
            environment_factors = {}

        total_cost = 0
        cost_breakdown = {}

        for equipment in equipment_list:
            # Check phase equipment mappings first
            if equipment in self.phase_mappings:
                phase_mapping = self.phase_mappings[equipment]
                base_equipment = phase_mapping['maps_to']
                quantity_multiplier = phase_mapping.get('quantity_multiplier', 1.0)
                
                if base_equipment in self.cost_mappings:
                    mapping = self.cost_mappings[base_equipment]
                    base_cost = mapping['base_cost_usd'] * quantity_multiplier

                    # Apply complexity and labor factors
                    cost = base_cost * mapping.get('complexity_multiplier', 1.0)
                    cost *= mapping.get('labor_factor', 1.0)

                    # Apply environment scaling
                    for factor, multiplier in environment_factors.items():
                        if factor in ['lunar_operations', 'orbital_operations', 'deep_space_operations',
                                    'planetary_surface', 'extreme_environment', 'radiation_intense', 'thermal_extreme']:
                            cost *= multiplier

                    # Add space operations multiplier
                    cost *= 2.5  # General space operations cost

                    cost_breakdown[equipment] = int(cost)
                    total_cost += cost
                    continue
            
            # Check direct equipment mappings
            if equipment in self.cost_mappings:
                mapping = self.cost_mappings[equipment]
                base_cost = mapping['base_cost_usd']

                # Apply complexity and labor factors
                cost = base_cost * mapping.get('complexity_multiplier', 1.0)
                cost *= mapping.get('labor_factor', 1.0)

                # Apply environment scaling
                for factor, multiplier in environment_factors.items():
                    if factor in ['lunar_operations', 'orbital_operations', 'deep_space_operations',
                                'planetary_surface', 'extreme_environment', 'radiation_intense', 'thermal_extreme']:
                        cost *= multiplier

                # Add space operations multiplier
                cost *= 2.5  # General space operations cost

                cost_breakdown[equipment] = int(cost)
                total_cost += cost
            else:
                # Fallback: estimate based on equipment name
                estimated_cost = self.estimate_equipment_cost(equipment)
                cost_breakdown[equipment] = estimated_cost
                total_cost += estimated_cost

        return int(total_cost), cost_breakdown

    def estimate_equipment_cost(self, equipment_name):
        """Estimate cost for equipment not in mappings"""
        # Simple estimation based on keywords
        base_estimates = {
            'habitat': 5000000,
            'module': 2000000,
            'system': 3000000,
            'unit': 1000000,
            'facility': 8000000,
            'infrastructure': 10000000
        }

        for keyword, cost in base_estimates.items():
            if keyword in equipment_name.lower():
                return cost

        return 1500000  # Default estimate

    def update_mission_manifest(self, manifest_path):
        """Update a mission manifest with calculated costs"""
        with open(manifest_path, 'r') as f:
            manifest = json.load(f)

        # Determine environment factors based on mission
        env_factors = {}
        target = manifest.get('target_environment', '').lower()
        if 'lunar' in target or 'luna' in target:
            env_factors['lunar_operations'] = 1.8
        elif 'orbital' in target or 'leo' in target or 'l1' in target:
            env_factors['orbital_operations'] = 2.2
        elif 'deep' in target or 'saturn' in target or 'titan' in target:
            env_factors['deep_space_operations'] = 3.0
        elif 'mars' in target or 'venus' in target:
            env_factors['planetary_surface'] = 2.5
            if 'venus' in target:
                env_factors['extreme_environment'] = 4.0
                env_factors['thermal_extreme'] = 2.3

        # Update each phase
        for phase in manifest.get('phases', []):
            if 'resource_requirements' in phase and 'equipment' in phase['resource_requirements']:
                equipment_list = phase['resource_requirements']['equipment']
                calculated_cost, breakdown = self.calculate_equipment_cost(equipment_list, env_factors)

                # Update the funding amount
                phase['resource_requirements']['calculated_cost_usd'] = calculated_cost
                phase['resource_requirements']['cost_breakdown'] = breakdown

        # Recalculate total funding
        total_funding = sum(
            phase.get('resource_requirements', {}).get('calculated_cost_usd', 0)
            for phase in manifest.get('phases', [])
        )

        # Update metadata
        if 'metadata' not in manifest:
            manifest['metadata'] = {}
        manifest['metadata']['calculated_total_funding_usd'] = total_funding
        manifest['metadata']['cost_calculation_date'] = '2026-02-03'
        manifest['metadata']['cost_methodology'] = 'equipment_based_calculation'

        # Write back
        with open(manifest_path, 'w') as f:
            json.dump(manifest, f, indent=2)

        return total_funding

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 calculate_mission_costs.py <mission_manifest.json>")
        sys.exit(1)

    manifest_path = sys.argv[1]
    calculator = MissionCostCalculator()

    print(f"Calculating costs for {manifest_path}...")
    total_cost = calculator.update_mission_manifest(manifest_path)
    print(f"Updated manifest with total calculated cost: ${total_cost:,} USD")

if __name__ == "__main__":
    main()