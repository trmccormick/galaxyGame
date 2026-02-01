#!/bin/bash
# check_prerequisites.sh
# Verify all tools and dependencies are ready for GeoTIFF processing

echo "🔍 Checking Prerequisites for GeoTIFF Processing"
echo "================================================"
echo ""

# Check GDAL
echo -n "Checking GDAL installation... "
if command -v gdal_translate &> /dev/null; then
    echo "✅ GDAL found"
    GDAL_VERSION=$(gdal_translate --version | head -1)
    echo "   Version: $GDAL_VERSION"
else
    echo "❌ GDAL not found"
    echo "   Install with: brew install gdal  (macOS) or apt-get install gdal-bin (Ubuntu)"
    exit 1
fi

# Check NetCDF support
echo -n "Checking NetCDF support in GDAL... "
if gdal_translate --formats | grep -i netcdf &> /dev/null; then
    echo "✅ NetCDF supported"
else
    echo "❌ NetCDF not supported"
    echo "   GDAL needs NetCDF driver. Reinstall GDAL with NetCDF support."
    exit 1
fi

# Check Ruby
echo -n "Checking Ruby installation... "
if command -v ruby &> /dev/null; then
    echo "✅ Ruby found"
    RUBY_VERSION=$(ruby --version | cut -d' ' -f2)
    echo "   Version: $RUBY_VERSION"
else
    echo "❌ Ruby not found"
    exit 1
fi

# Check wget
echo -n "Checking wget for downloads... "
if command -v wget &> /dev/null; then
    echo "✅ wget found"
else
    echo "❌ wget not found"
    echo "   Install with: brew install wget (macOS)"
    exit 1
fi

# Check internet connectivity
echo -n "Checking internet connectivity... "
if wget --timeout=5 --tries=1 -qO- https://www.google.com > /dev/null 2>&1; then
    echo "✅ Internet available"
else
    echo "❌ No internet connectivity"
    echo "   Required for downloading ETOPO data"
    exit 1
fi

# Check disk space (need at least 200MB free)
echo -n "Checking available disk space... "
DISK_SPACE=$(df -m . | tail -1 | awk '{print $4}')
if [ "$DISK_SPACE" -gt 200 ]; then
    echo "✅ ${DISK_SPACE}MB available (sufficient)"
else
    echo "❌ Only ${DISK_SPACE}MB available (need 200MB+)"
    exit 1
fi

# Check if directories exist (flexible for Docker environment)
echo -n "Checking project structure... "
if [ -d "lib" ] && [ -d "app" ] && [ -f "Gemfile" ]; then
    echo "✅ Galaxy Game project found"
    # Create data directory if it doesn't exist
    mkdir -p data/ai_patterns data/geotiff/temp data/test_maps
else
    echo "❌ Not in Galaxy Game project directory"
    echo "   Run from galaxy_game project directory"
    exit 1
fi

echo ""
echo "🎉 All prerequisites met!"
echo "🚀 Ready to run overnight GeoTIFF setup"
echo ""
echo "Next steps:"
echo "1. Run: ./overnight_geotiff_setup.sh"
echo "2. Go to bed (runs ~4-5 hours)"
echo "   - data/test_maps/earth_with_patterns.json"
