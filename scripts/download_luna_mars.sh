#!/bin/bash
# scripts/download_luna_mars.sh

set -e

# Set project root (assuming script is run from project root)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "=========================================="
echo "Downloading Luna and Mars Elevation Data"
echo "Started at: $(date)"
echo "=========================================="
echo ""

mkdir -p "$PROJECT_ROOT/data/geotiff/raw"
mkdir -p "$PROJECT_ROOT/data/geotiff/processed"
mkdir -p "$PROJECT_ROOT/logs"

exec > >(tee -a "$PROJECT_ROOT/logs/download_bodies_$(date +%Y%m%d_%H%M%S).log") 2>&1

# Download Luna (Moon) DEM
echo "Step 1: Downloading Lunar DEM from USGS..."
echo "  Source: LRO LOLA Global DEM (118m resolution)"
echo "  Size: ~350MB (this will take a few minutes)"
echo ""

curl -L -C - -o "$PROJECT_ROOT/data/geotiff/raw/luna_lola_118m.tif" \
    "https://planetarymaps.usgs.gov/mosaic/Lunar_LRO_LOLA_Global_LDEM_118m_Mar2014.tif"

if [ $? -eq 0 ]; then
    echo "✓ Luna DEM downloaded successfully"
    ls -lh "$PROJECT_ROOT/data/geotiff/raw/luna_lola_118m.tif"
else
    echo "❌ Luna download failed"
    exit 1
fi

echo ""

# Download Mars DEM
echo "Step 2: Downloading Mars DEM from USGS..."
echo "  Source: MGS MOLA Global DEM (463m resolution)"
echo "  Size: ~180MB (this will take a few minutes)"
echo ""

curl -L -C - -o "$PROJECT_ROOT/data/geotiff/raw/mars_mola_463m.tif" \
    "https://planetarymaps.usgs.gov/mosaic/Mars_MGS_MOLA_DEM_mosaic_global_463m.tif"

if [ $? -eq 0 ]; then
    echo "✓ Mars DEM downloaded successfully"
    ls -lh "$PROJECT_ROOT/data/geotiff/raw/mars_mola_463m.tif"
else
    echo "❌ Mars download failed"
    exit 1
fi

echo ""

# Process Luna to training resolution
echo "Step 3: Processing Luna to 1800x900 resolution..."
gdal_translate -outsize 1800 900 -r bilinear \
    -co COMPRESS=DEFLATE \
    -co PREDICTOR=2 \
    "$PROJECT_ROOT/data/geotiff/raw/luna_lola_118m.tif" \
    "$PROJECT_ROOT/data/geotiff/processed/luna_1800x900.tif"

echo "✓ Luna processed"
ls -lh "$PROJECT_ROOT/data/geotiff/processed/luna_1800x900.tif"

echo ""

# Process Mars to training resolution
echo "Step 4: Processing Mars to 1800x900 resolution..."
gdal_translate -outsize 1800 900 -r bilinear \
    -co COMPRESS=DEFLATE \
    -co PREDICTOR=2 \
    "$PROJECT_ROOT/data/geotiff/raw/mars_mola_463m.tif" \
    "$PROJECT_ROOT/data/geotiff/processed/mars_1800x900.tif"

echo "✓ Mars processed"
ls -lh "$PROJECT_ROOT/data/geotiff/processed/mars_1800x900.tif"

echo ""

# Convert to compressed ASCII for Ruby processing
echo "Step 5: Converting to ASCII format for Ruby..."

gdal_translate -of AAIGrid \
    "$PROJECT_ROOT/data/geotiff/processed/luna_1800x900.tif" \
    "$PROJECT_ROOT/data/geotiff/processed/luna_1800x900.asc"

gzip -9 "$PROJECT_ROOT/data/geotiff/processed/luna_1800x900.asc"

echo "✓ Luna ASCII created"

gdal_translate -of AAIGrid \
    "$PROJECT_ROOT/data/geotiff/processed/mars_1800x900.tif" \
    "$PROJECT_ROOT/data/geotiff/processed/mars_1800x900.asc"

gzip -9 "$PROJECT_ROOT/data/geotiff/processed/mars_1800x900.asc"

echo "✓ Mars ASCII created"

echo ""
echo "=========================================="
echo "DOWNLOAD & PROCESSING COMPLETE!"
echo "Finished at: $(date)"
echo "=========================================="
echo ""
echo "Files ready:"
ls -lh "$PROJECT_ROOT/data/geotiff/processed/*.asc.gz"
echo ""
echo "Ready for Night 2 multi-body pattern extraction"