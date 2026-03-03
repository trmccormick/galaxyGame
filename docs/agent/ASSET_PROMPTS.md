# Asset Generation Prompts for Galaxy Game

This document contains the ChatGPT/DALL-E prompts used to generate visual assets for the Civ-Sim-EVE hybrid game engine. These prompts are designed for 2:1 isometric sprites with transparency-ready backgrounds.

## Hub & Infrastructure Assets

### Landed Heavy Lift Launcher (HLL)
"A high-detail 2:1 isometric game sprite of a vertical heavy-lift launcher, 50 meters tall, made of polished stainless steel. Quad-pod landing legs deployed on a flat base. High-contrast lighting from the top-right, reflective metallic textures. Isolated on a solid, flat, high-contrast neon green background for easy transparency masking. No ground, no shadows, center-frame."

### Planetary Umbilical Hub (PUH)
"A 2:1 isometric industrial utility module. A dense, boxy unit with multiple yellow-rimmed power ports and thick bundled cables coiled at the base. Stainless steel and hazard-stripe accents. Isolated on a solid flat white background, game asset style, no floor."

## Robot & Unit Assets

### CAR-300 (Utility Robot)
"A 2:1 isometric game unit of the CAR-300 assembly robot. Low-profile chassis, six high-torque wheels, and two articulated manipulator arms. Industrial white and orange paint. Isolated on a solid transparent-ready flat white background, center-aligned."

### SMR-500 (Mapping Robot)
"A small, compact 2:1 isometric mapping robot (SMR-500). Rounded silver body covered in blue-glowing sensor lenses and a rotating LIDAR turret on top. Isolated on a solid flat white background, sharp edges."

### HRV-400 (Harvester Robot)
"An industrial 2:1 isometric resource harvesting robot. Large open collection hopper on the back, front-mounted regolith scoop. Weathered, dusty metal texture. Isolated on a solid flat white background."

### MRR-100 (Maintenance Robot)
"A 2:1 isometric maintenance robot with a welding torch arm and tool-rack back-plate. Rugged industrial design. Isolated on a solid flat white background."

### LTR-100 (Logistics Robot)
"A 2:1 isometric logistics robot with cargo handling arms and storage compartments. Modular design for transport tasks. Isolated on a solid flat white background."

### LSPU (Surface Prep Unit)
"A 2:1 isometric specialized construction vehicle with microwave-sintering plates underneath for smoothing regolith. Wide, flat-bottomed design. Isolated on a solid flat white background."

## Fabrication & Processing Assets

### Planetary I-Beam Printing Unit
"A 2:1 isometric industrial 3D printer unit. A large rectangular base with a retractable gantry arm that is mid-action printing a dark grey iron I-beam. Isolated on a solid flat white background, no floor textures."

### 3D Regolith Shell Printer
"A 2:1 isometric large-scale construction robot with a long, multi-jointed gantry arm printing a rough, grey regolith dome over an inflatable tank. Isolated on a solid flat white background."

### Thermal Extraction Unit (TEU)
"A heavy 2:1 isometric furnace module with a glowing orange intake vent and heavy thermal insulation blankets. Isolated on a solid flat white background."

### Planetary Volatiles Extractor (PVE Mk1)
"A complex 2:1 isometric industrial processor with intake pipes, a central heating chamber, and high-pressure valves. Metallic grey with yellow hazard stripes. Isolated on a solid flat white background."

### Gas Separator Unit
"A 2:1 isometric vertical gas processing manifold with three connected pressurized cylinders and visible gauges. Isolated on a solid flat white background."

## Storage & Logistics Assets

### Cryogenic Distribution Hub
"A 2:1 isometric logistics node with a central pump station surrounded by insulated pipe-valves and a docking interface. Stainless steel with blue 'LOX' and 'CH4' labels. Isolated on a solid flat white background."

### Inflatable Gas Storage Array
"A 2:1 isometric row of four white pressurized 'pillow' tanks held down by heavy steel straps and connected by a manifold line. Isolated on a solid flat white background."

## Terrain & Structural Assets

### Standard I-Beam Skeleton (Tile)
"A 2:1 isometric structural skeleton made of 3D-printed iron I-beams forming a perfect grid over a cratered lunar surface. The beams have a visible layered 3D-printed texture. Seamless edges for tiling. Isolated on a solid flat neon green background."

### Safeguard Panel (Middle Surface Tile)
"A 2:1 isometric structural tile with a grid of iron I-beams holding semi-transparent reinforced glass panels and dark solar photovoltaic strips. Isolated on a solid flat neon green background."

### Lava Tube Skylight (Empty Terrain)
"A 2:1 isometric terrain tile showing a jagged, dark circular opening in the cratered lunar surface, revealing a deep cavern below. Isolated on a solid flat neon green background."

### Skylight Support Framework
"A 2:1 isometric structural cap for a lava tube with a heavy hexagonal web of dark iron I-beams designed to fit over a hole. Isolated on a solid flat neon green background."

## Implementation Notes

- **Transparency**: All prompts use "solid flat white" or "neon green" backgrounds for easy removal in image editing software.
- **Scale Consistency**: Reference the HLL (large) and CAR-300 (small) for relative sizing.
- **Isometric Angle**: All assets use 2:1 isometric perspective with top-right lighting.
- **Game Integration**: Assets are designed for Civ4/FreeCiv-style tile engines with 8-directional unit sprites.