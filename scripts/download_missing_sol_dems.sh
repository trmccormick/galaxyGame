#!/bin/bash
# Download and process DEMs for all missing Sol system bodies
# Extends the Earth/Luna/Mars pattern to complete coverage

set -e

echo "=========================================="
echo "Downloading Missing Sol System DEMs"
echo "Started at: $(date)"
echo "=========================================="
echo ""

mkdir -p data/geotiff/raw
mkdir -p data/geotiff/processed
mkdir -p logs

exec > >(tee -a logs/download_sol_bodies_$(date +%Y%m%d_%H%M%S).log) 2>&1

# ============================================================================
# MERCURY - MESSENGER Mission Data
# ============================================================================
echo "Step 1: Downloading Mercury DEM from USGS..."
echo "  Source: MESSENGER MDIS Global DEM (665m resolution)"
echo "  Size: ~120MB"
echo ""

wget -c -O data/geotiff/raw/mercury_messenger_665m.tif \
    "https://planetarymaps.usgs.gov/mosaic/Mercury_Messenger_USGS_DEM_Global_665m_v2.tif"

if [ $? -eq 0 ]; then
    echo "✓ Mercury DEM downloaded successfully"
    ls -lh data/geotiff/raw/mercury_messenger_665m.tif
else
    echo "❌ Mercury download failed"
    exit 1
fi

echo ""

# ============================================================================
# VENUS - Magellan Mission Data
# ============================================================================
echo "Step 2: Downloading Venus DEM from USGS..."
echo "  Source: Magellan SAR Topography (4641m resolution)"
echo "  Size: ~250MB"
echo ""

wget -c -O data/geotiff/raw/venus_magellan_4641m.tif \
    "https://planetarymaps.usgs.gov/mosaic/Venus_Magellan_Topography_Global_4641m.tif"

if [ $? -eq 0 ]; then
    echo "✓ Venus DEM downloaded successfully"
    ls -lh data/geotiff/raw/venus_magellan_4641m.tif
else
    echo "❌ Venus download failed"
    exit 1
fi

echo ""

# ============================================================================
# TITAN - Cassini Mission Data
# ============================================================================
echo "Step 3: Downloading Titan DEM from USGS..."
echo "  Source: Cassini RADAR Topography"
echo "  Size: ~80MB"
echo ""

# Note: Titan has partial coverage from Cassini radar
wget -c -O data/geotiff/raw/titan_cassini_radar.tif \
    "https://planetarymaps.usgs.gov/mosaic/Titan_Cassini_RADAR_Global_8ppd.tif"

if [ $? -eq 0 ]; then
    echo "✓ Titan DEM downloaded successfully"
    ls -lh data/geotiff/raw/titan_cassini_radar.tif
else
    echo "⚠️  Titan download failed - will use procedural generation"
    # Don't exit - Titan data may not be available, fallback is acceptable
fi

echo ""

# ============================================================================
# IO - Galileo Mission Data
# ============================================================================
echo "Step 4: Downloading Io DEM from USGS..."
echo "  Source: Galileo/Voyager combined global mosaic"
echo "  Size: ~150MB"
echo ""

wget -c -O data/geotiff/raw/io_galileo_dem.tif \
    "https://planetarymaps.usgs.gov/mosaic/Io_GalileoSSI_Global_Mosaic_ClrMerge_1km.tif"

if [ $? -eq 0 ]; then
    echo "✓ Io DEM downloaded successfully"
    ls -lh data/geotiff/raw/io_galileo_dem.tif
else
    echo "⚠️  Io download failed - will use procedural generation"
fi

echo ""

# ============================================================================
# EUROPA - Galileo Mission Data
# ============================================================================
echo "Step 5: Downloading Europa DEM from USGS..."
echo "  Source: Galileo/Voyager global mosaic"
echo "  Size: ~100MB"
echo ""

wget -c -O data/geotiff/raw/europa_galileo_dem.tif \
    "https://planetarymaps.usgs.gov/mosaic/Europa_Voyager_GalileoSSI_global_mosaic_500m.tif"

if [ $? -eq 0 ]; then
    echo "✓ Europa DEM downloaded successfully"
    ls -lh data/geotiff/raw/europa_galileo_dem.tif
else
    echo "⚠️  Europa download failed - will use procedural generation"
fi

echo ""

# ============================================================================
# GANYMEDE - Galileo Mission Data
# ============================================================================
echo "Step 6: Downloading Ganymede DEM from USGS..."
echo "  Source: Galileo/Voyager global mosaic"
echo "  Size: ~200MB"
echo ""

wget -c -O data/geotiff/raw/ganymede_galileo_dem.tif \
    "https://planetarymaps.usgs.gov/mosaic/Ganymede_Voyager_GalileoSSI_global_mosaic_1km.tif"

if [ $? -eq 0 ]; then
    echo "✓ Ganymede DEM downloaded successfully"
    ls -lh data/geotiff/raw/ganymede_galileo_dem.tif
else
    echo "⚠️  Ganymede download failed - will use procedural generation"
fi

echo ""

# ============================================================================
# CALLISTO - Galileo Mission Data
# ============================================================================
echo "Step 7: Downloading Callisto DEM from USGS..."
echo "  Source: Galileo/Voyager global mosaic"
echo "  Size: ~150MB"
echo ""

wget -c -O data/geotiff/raw/callisto_galileo_dem.tif \
    "https://planetarymaps.usgs.gov/mosaic/Callisto_Voyager_GalileoSSI_global_mosaic_1km.tif"

if [ $? -eq 0 ]; then
    echo "✓ Callisto DEM downloaded successfully"
    ls -lh data/geotiff/raw/callisto_galileo_dem.tif
else
    echo "⚠️  Callisto download failed - will use procedural generation"
fi

echo ""

# ============================================================================
# ENCELADUS - Cassini Mission Data
# ============================================================================
echo "Step 8: Downloading Enceladus DEM from USGS..."
echo "  Source: Cassini ISS global mosaic"
echo "  Size: ~60MB"
echo ""

wget -c -O data/geotiff/raw/enceladus_cassini_dem.tif \
    "https://planetarymaps.usgs.gov/mosaic/Enceladus_Cassini_mosaic_global_110m.tif"

if [ $? -eq 0 ]; then
    echo "✓ Enceladus DEM downloaded successfully"
    ls -lh data/geotiff/raw/enceladus_cassini_dem.tif
else
    echo "⚠️  Enceladus download failed - will use procedural generation"
fi

echo ""

# ============================================================================
# PROCESSING - Resample all to 1800x900 training resolution
# ============================================================================
echo "=========================================="
echo "Processing Downloaded DEMs"
echo "=========================================="
echo ""

# Function to process a DEM if it exists
process_dem() {
    local body=$1
    local input_file=$2
    
    if [ -f "$input_file" ]; then
        echo "Processing $body to 1800x900..."
        
        gdalwarp -tr 0.2 0.2 \
            -r bilinear \
            -co COMPRESS=DEFLATE \
            -co PREDICTOR=2 \
            "$input_file" \
            "data/geotiff/processed/${body}_1800x900.tif"
        
        echo "Converting $body to ASCII..."
        gdal_translate -of AAIGrid \
            "data/geotiff/processed/${body}_1800x900.tif" \
            "data/geotiff/processed/${body}_1800x900.asc"
        
        echo "Compressing $body ASCII..."
        gzip -9 "data/geotiff/processed/${body}_1800x900.asc"
        
        echo "✓ $body processed"
        ls -lh "data/geotiff/processed/${body}_1800x900.asc.gz"
        echo ""
    else
        echo "⊘ Skipping $body (source file not found)"
        echo ""
    fi
}

# Process each body
process_dem "mercury" "data/geotiff/raw/mercury_messenger_665m.tif"
process_dem "venus" "data/geotiff/raw/venus_magellan_4641m.tif"
process_dem "titan" "data/geotiff/raw/titan_cassini_radar.tif"
process_dem "io" "data/geotiff/raw/io_galileo_dem.tif"
process_dem "europa" "data/geotiff/raw/europa_galileo_dem.tif"
process_dem "ganymede" "data/geotiff/raw/ganymede_galileo_dem.tif"
process_dem "callisto" "data/geotiff/raw/callisto_galileo_dem.tif"
process_dem "enceladus" "data/geotiff/raw/enceladus_cassini_dem.tif"

echo "=========================================="
echo "DOWNLOAD & PROCESSING COMPLETE!"
echo "Finished at: $(date)"
echo "=========================================="
echo ""
echo "Files ready for pattern extraction:"
ls -lh data/geotiff/processed/*.asc.gz
echo ""
echo "Next step: Run pattern extraction script"
