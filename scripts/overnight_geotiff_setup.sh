#!/bin/bash
# scripts/overnight_geotiff_setup.sh

set -e  # Exit on error

echo "=== NIGHT 1: GeoTIFF Download & Processing ==="
echo "Started at: $(date)"

# Create directories
mkdir -p data/geotiff/raw
mkdir -p data/geotiff/processed
mkdir -p data/ai_patterns
mkdir -p logs

# Log everything
exec > >(tee -a logs/night1_$(date +%Y%m%d).log) 2>&1

echo "Step 1: Downloading ETOPO 2022 (70MB)..."
wget -c https://www.ngdc.noaa.gov/thredds/fileServer/global/ETOPO2022/60s/60s_surface_elev_netcdf/ETOPO_2022_v1_60s_N90W180_surface.nc \
    -O data/geotiff/raw/etopo_2022.nc

echo "Step 2: Verifying download..."
if [ -f data/geotiff/raw/etopo_2022.nc ]; then
    file_size=$(wc -c < data/geotiff/raw/etopo_2022.nc)
    echo "Downloaded successfully: $file_size bytes"
else
    echo "ERROR: Download failed!"
    exit 1
fi

echo "Step 3: Converting NetCDF to GeoTIFF..."
gdal_translate -of GTiff \
    -co COMPRESS=DEFLATE \
    -co PREDICTOR=2 \
    -co TILED=YES \
    NETCDF:"data/geotiff/raw/etopo_2022.nc":z \
    data/geotiff/processed/earth_elevation.tif

echo "Step 4: Creating resampled versions for different use cases..."

# High-res for detailed analysis (3600x1800 = 0.1 degree)
gdalwarp -tr 0.1 0.1 \
    -r bilinear \
    -co COMPRESS=DEFLATE \
    -co PREDICTOR=2 \
    data/geotiff/processed/earth_elevation.tif \
    data/geotiff/processed/earth_3600x1800.tif

# Medium-res for AI training (1800x900 = 0.2 degree)
gdalwarp -tr 0.2 0.2 \
    -r bilinear \
    -co COMPRESS=DEFLATE \
    -co PREDICTOR=2 \
    data/geotiff/processed/earth_elevation.tif \
    data/geotiff/processed/earth_1800x900.tif

# Low-res for quick testing (900x450 = 0.4 degree)
gdalwarp -tr 0.4 0.4 \
    -r bilinear \
    -co COMPRESS=DEFLATE \
    -co PREDICTOR=2 \
    data/geotiff/processed/earth_elevation.tif \
    data/geotiff/processed/earth_900x450.tif

echo "Step 5: Generating statistics..."
gdalinfo -stats data/geotiff/processed/earth_1800x900.tif > data/geotiff/processed/earth_stats.txt

echo "Step 6: Converting to simple ASCII format for Ruby..."
gdal_translate -of AAIGrid \
    data/geotiff/processed/earth_1800x900.tif \
    data/geotiff/processed/earth_1800x900.asc

echo "Step 7: Compressing ASCII for storage..."
gzip -9 data/geotiff/processed/earth_1800x900.asc

echo "=== NIGHT 1 COMPLETE ==="
echo "Finished at: $(date)"
echo ""
echo "Files created:"
ls -lh data/geotiff/processed/
echo ""
echo "Ready for Night 2: Pattern Extraction"