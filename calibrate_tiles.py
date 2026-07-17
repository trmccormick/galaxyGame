#!/usr/bin/env python3
from PIL import Image
import os

INPUT_IMAGE = '/Users/tam0013/Documents/git/galaxyGame/data/images/test-images/Space colonization terrain tileset.png'

img = Image.open(INPUT_IMAGE)
width, height = img.size
print(f"Image dimensions: {width}x{height}")

# Get the first few rows and columns to analyze pixel patterns
# Look for vertical and horizontal dividing lines (white/light borders)

# Sample horizontal line (middle of image)
h_sample = height // 2
h_line = img.crop((0, h_sample, width, h_sample + 1))
h_pixels = h_line.load()

# Find white/light pixels (borders)
print(f"\nAnalyzing horizontal line at y={h_sample}:")
consecutive_light = 0
light_ranges = []
for x in range(width):
    r, g, b = h_pixels[x, 0][:3]  # Get RGB, ignore alpha
    brightness = (r + g + b) / 3
    if brightness > 200:  # Light pixels
        if consecutive_light == 0:
            light_start = x
        consecutive_light += 1
    else:
        if consecutive_light > 0:
            light_ranges.append((light_start, x, consecutive_light))
        consecutive_light = 0

print(f"Light pixel ranges (potential column dividers): {light_ranges[:15]}")

# Sample vertical line (middle of image)
v_sample = width // 2
v_line = img.crop((v_sample, 0, v_sample + 1, height))
v_pixels = v_line.load()

print(f"\nAnalyzing vertical line at x={v_sample}:")
consecutive_light = 0
light_ranges = []
for y in range(height):
    r, g, b = v_pixels[0, y][:3]
    brightness = (r + g + b) / 3
    if brightness > 200:
        if consecutive_light == 0:
            light_start = y
        consecutive_light += 1
    else:
        if consecutive_light > 0:
            light_ranges.append((light_start, y, consecutive_light))
        consecutive_light = 0

print(f"Light pixel ranges (potential row dividers): {light_ranges[:15]}")

# Try to detect the grid by looking at the first row and column
print("\n=== Detecting grid structure ===")

# Scan first column (left edge)
first_col = img.crop((0, 0, 1, height))
first_col_pixels = first_col.load()
print("\nFirst column brightness profile:")
for y in range(0, height, 50):
    r, g, b = first_col_pixels[0, y][:3]
    brightness = (r + g + b) / 3
    print(f"  y={y}: brightness={brightness:.0f}")

# Scan first row (top edge)
first_row = img.crop((0, 0, width, 1))
first_row_pixels = first_row.load()
print("\nFirst row brightness profile:")
for x in range(0, width, 150):
    r, g, b = first_row_pixels[x, 0][:3]
    brightness = (r + g + b) / 3
    print(f"  x={x}: brightness={brightness:.0f}")
