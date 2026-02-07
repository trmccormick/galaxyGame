#!/usr/bin/env python3
"""
Mission Requirements Validation Script

This script validates that all mission requirements are properly defined:
1. Equipment referenced in phases has cost mappings
2. Blueprint dependencies exist
3. Material requirements are satisfied

Usage: python3 validate_mission_requirements.py
"""

import json
import sys
import os
from pathlib import Path

class MissionRequirementsValidator:
    def __init__(self, data_dir="data/json-data"):
        self.data_dir = Path(data_dir)
        self.cost_mappings = {}
        self.phase_mappings = {}
        self.blueprints = {}
        self.materials = {}
        self.items = {}
        self.validation_results = {
            "equipment_coverage": {"total": 0, "mapped": 0, "missing": []},
            "blueprint_dependencies": {"total": 0, "found": 0, "missing": []},
            "material_availability": {"total": 0, "available": 0, "missing": []}
        }
        self.load_data()

    def load_data(self):
        """Load all relevant data structures"""
        # Load cost calculation system
        cost_file = self.data_dir / "cost_calculation_system.json"
        if cost_file.exists():
            with open(cost_file, 'r') as f:
                cost_data = json.load(f)
                self.cost_mappings = cost_data.get('equipment_cost_mappings', {})
                self.phase_mappings = cost_data.get('phase_equipment_mappings', {})

        # Load blueprints
        blueprints_dir = self.data_dir / "blueprints"
        for root, dirs, files in os.walk(blueprints_dir):
            for file in files:
                if file.endswith('.json'):
                    try:
                        with open(os.path.join(root, file), 'r') as f:
                            blueprint = json.load(f)
                            blueprint_id = blueprint.get('id', file.replace('.json', ''))
                            self.blueprints[blueprint_id] = blueprint
                    except:
                        continue

        # Load materials
        materials_dir = self.data_dir / "resources/materials"
        for root, dirs, files in os.walk(materials_dir):
            for file in files:
                if file.endswith('.json'):
                    try:
                        with open(os.path.join(root, file), 'r') as f:
                            material = json.load(f)
                            material_id = material.get('id', file.replace('.json', ''))
                            self.materials[material_id] = material
                    except:
                        continue

        # Load items
        items_dir = self.data_dir / "items"
        for root, dirs, files in os.walk(items_dir):
            for file in files:
                if file.endswith('.json'):
                    try:
                        with open(os.path.join(root, file), 'r') as f:
                            item = json.load(f)
                            item_id = item.get('id', file.replace('.json', ''))
                            self.items[item_id] = item
                    except:
                        continue

    def validate_equipment_coverage(self):
        """Validate that all equipment referenced in mission phases has cost mappings"""
        print("Validating equipment coverage...")

        # Collect all equipment from phase files
        phases_dir = self.data_dir / "missions/phases"
        all_equipment = set()

        for root, dirs, files in os.walk(phases_dir):
            for file in files:
                if file.endswith('.json'):
                    try:
                        with open(os.path.join(root, file), 'r') as f:
                            phase_data = json.load(f)
                            if 'tasks' in phase_data:
                                for task in phase_data['tasks']:
                                    if 'resources_required' in task:
                                        for equipment in task['resources_required']:
                                            all_equipment.add(equipment)
                    except:
                        continue

        # Check coverage
        self.validation_results["equipment_coverage"]["total"] = len(all_equipment)

        for equipment in all_equipment:
            if equipment in self.cost_mappings or equipment in self.phase_mappings:
                self.validation_results["equipment_coverage"]["mapped"] += 1
            else:
                self.validation_results["equipment_coverage"]["missing"].append(equipment)

        print(f"Equipment coverage: {self.validation_results['equipment_coverage']['mapped']}/{self.validation_results['equipment_coverage']['total']} mapped")

    def validate_blueprint_dependencies(self):
        """Validate that blueprint dependencies exist"""
        print("Validating blueprint dependencies...")

        # Check blueprints that reference other blueprints
        for blueprint_id, blueprint in self.blueprints.items():
            if 'dependencies' in blueprint:
                for dep in blueprint['dependencies']:
                    self.validation_results["blueprint_dependencies"]["total"] += 1
                    if dep in self.blueprints:
                        self.validation_results["blueprint_dependencies"]["found"] += 1
                    else:
                        self.validation_results["blueprint_dependencies"]["missing"].append(f"{blueprint_id} -> {dep}")

        print(f"Blueprint dependencies: {self.validation_results['blueprint_dependencies']['found']}/{self.validation_results['blueprint_dependencies']['total']} found")

    def validate_material_availability(self):
        """Validate that materials required by blueprints are available"""
        print("Validating material availability...")

        for blueprint_id, blueprint in self.blueprints.items():
            if 'material_requirements' in blueprint:
                for req in blueprint['material_requirements']:
                    material_id = req.get('material')
                    if material_id:
                        self.validation_results["material_availability"]["total"] += 1
                        if material_id in self.materials:
                            self.validation_results["material_availability"]["available"] += 1
                        else:
                            self.validation_results["material_availability"]["missing"].append(f"{blueprint_id} -> {material_id}")

        print(f"Material availability: {self.validation_results['material_availability']['available']}/{self.validation_results['material_availability']['total']} available")

    def generate_report(self):
        """Generate validation report"""
        print("\n" + "="*60)
        print("MISSION REQUIREMENTS VALIDATION REPORT")
        print("="*60)

        # Equipment coverage
        eq = self.validation_results["equipment_coverage"]
        print(f"\nEquipment Coverage: {eq['mapped']}/{eq['total']} ({eq['mapped']/eq['total']*100:.1f}%)")
        if eq["missing"]:
            print("Missing equipment mappings:")
            for item in eq["missing"]:
                print(f"  - {item}")

        # Blueprint dependencies
        bp = self.validation_results["blueprint_dependencies"]
        if bp["total"] > 0:
            print(f"\nBlueprint Dependencies: {bp['found']}/{bp['total']} ({bp['found']/bp['total']*100:.1f}%)")
            if bp["missing"]:
                print("Missing blueprint dependencies:")
                for item in bp["missing"]:
                    print(f"  - {item}")

        # Material availability
        mat = self.validation_results["material_availability"]
        if mat["total"] > 0:
            print(f"\nMaterial Availability: {mat['available']}/{mat['total']} ({mat['available']/mat['total']*100:.1f}%)")
            if mat["missing"]:
                print("Missing materials:")
                for item in mat["missing"]:
                    print(f"  - {item}")

        # Overall assessment
        all_good = all([
            len(eq["missing"]) == 0,
            len(bp["missing"]) == 0,
            len(mat["missing"]) == 0
        ])

        print(f"\nOverall Status: {'✓ ALL REQUIREMENTS VALIDATED' if all_good else '⚠ ISSUES FOUND - REVIEW REQUIRED'}")
        return all_good

def main():
    validator = MissionRequirementsValidator()

    validator.validate_equipment_coverage()
    validator.validate_blueprint_dependencies()
    validator.validate_material_availability()

    return validator.generate_report()

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)