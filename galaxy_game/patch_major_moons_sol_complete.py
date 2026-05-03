import json
import sys

# List of major moons to update
MAJOR_MOONS = [
    "Luna", "Io", "Europa", "Ganymede", "Callisto", "Titan", "Rhea", "Iapetus", "Dione", "Tethys", "Enceladus", "Miranda", "Ariel", "Umbriel", "Titania", "Oberon", "Triton"
]

json_path = "/home/galaxy_game/app/data/json-data/star_systems/sol-complete.json"

with open(json_path, "r", encoding="utf-8") as f:
    data = json.load(f)

found = []
not_found = []
for body in data.get("celestial_bodies", []):
    if body.get("name") in MAJOR_MOONS:
        if "properties" not in body or not isinstance(body["properties"], dict):
            body["properties"] = {"major_moon": True}
        else:
            body["properties"]["major_moon"] = True
        found.append(body["name"])

for moon in MAJOR_MOONS:
    if moon not in found:
        not_found.append(moon)

with open(json_path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Updated moons:", found)
print("Not found:", not_found)
