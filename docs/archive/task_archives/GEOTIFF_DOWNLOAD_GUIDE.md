# GeoTIFF Training Data Sources - Complete Download Guide

## 🎯 Best Sources for Free GeoTIFF Elevation Data

### Option 1: OpenTopography (EASIEST - AWS Direct Download) ⭐ RECOMMENDED

**What**: SRTM GL1 Global 30m resolution elevation data, freely available via AWS S3

**Coverage**: Global (80% of Earth's land surface, 60°N to 56°S)

**Resolution**: 30 meters (~1 arc-second)

**Format**: GeoTIFF (ready to use!)

**Download Method** (No registration required!):

```bash
# Install AWS CLI
# On Ubuntu/Debian:
sudo apt-get install awscli

# On Mac:
brew install awscli

# List available files
aws s3 ls s3://raster/SRTM_GL1/ --recursive \
    --endpoint-url https://opentopography.s3.sdsc.edu \
    --no-sign-request

# Download entire dataset (WARNING: ~150GB)
aws s3 cp s3://raster/SRTM_GL1/ ./data/geotiff/srtm_gl1/ --recursive \
    --endpoint-url https://opentopography.s3.sdsc.edu \
    --no-sign-request

# Or download specific tiles (e.g., just North America)
aws s3 cp s3://raster/SRTM_GL1/North_America/ ./data/geotiff/north_america/ --recursive \
    --endpoint-url https://opentopography.s3.sdsc.edu \
    --no-sign-request
```

**URL**: https://portal.opentopography.org/raster?opentopoID=OTSRTM.082015.4326.1

**Pros**:
- ✅ No registration required
- ✅ Direct AWS download (fast!)
- ✅ Already in GeoTIFF format
- ✅ Void-filled (no missing data)

---

### Option 2: USGS EarthExplorer (Most Complete - Requires Registration)

**What**: SRTM 1 Arc-Second Global data in GeoTIFF format, approximately 25 MB per tile

**Coverage**: Global (60°N to 56°S)

**Resolution**: 30 meters (1 arc-second) or 90 meters (3 arc-seconds)

**Format**: GeoTIFF

**Download Steps**:

1. **Register for free account**:
   - Go to https://earthexplorer.usgs.gov/
   - Click "Register" (top right)
   - Fill out form (free, takes 2 minutes)
   - Confirm email

2. **Search and Download**:
   - Go to https://earthexplorer.usgs.gov/
   - Click "Data Sets" tab
   - Expand "Digital Elevation" → Select "SRTM 1 Arc-Second Global" (or "SRTM Void Filled")
   - Click "Results" tab
   - Click download icon next to desired tiles
   - Select "GeoTIFF" format

3. **Bulk Download** (for multiple tiles):
   - Use USGS download scripts (Python, Bash, etc.)
   - List of all 14,297 tile URLs: https://www.opentopodata.org/datasets/srtm/ (scroll down for `srtm30m_urls.txt`)

**URL**: https://earthexplorer.usgs.gov/

**Pros**:
- ✅ Official USGS source
- ✅ Multiple versions (void-filled, non-void-filled)
- ✅ Detailed metadata

**Cons**:
- ❌ Requires registration
- ❌ Download authentication can be tricky

---

### Option 3: NASA Earthdata (Requires NASA Account)

**What**: Original SRTM data from NASA

**Coverage**: Global (60°N to 56°S)

**Resolution**: 30 meters

**Download Steps**:

1. **Register**:
   - Go to https://urs.earthdata.nasa.gov/users/new
   - Create free NASA Earthdata account

2. **Download**:
   - Go to https://search.earthdata.nasa.gov/
   - Search for "SRTM"
   - Select dataset
   - Download tiles

**URL**: https://www.earthdata.nasa.gov/data/instruments/srtm

**Pros**:
- ✅ Official NASA source
- ✅ Research-grade data

**Cons**:
- ❌ Requires NASA account
- ❌ More complex authentication

---

### Option 4: Open Topo Data API (For Small Queries)

**What**: Free API to query SRTM 30m elevation data without downloading files

**Use Case**: Get elevation for specific coordinates programmatically

**Example**:
```bash
curl "https://api.opentopodata.org/v1/srtm30m?locations=57.688709,11.976404"

# Response:
{
  "results": [
    {
      "elevation": 55.0,
      "location": { "lat": 57.688709, "lng": 11.976404 },
      "dataset": "srtm30m"
    }
  ],
  "status": "OK"
}
```

**Pros**:
- ✅ No download needed
- ✅ No registration required
- ✅ Perfect for spot checks

**Cons**:
- ❌ Not suitable for bulk processing
- ❌ API rate limits

---

## 📦 Recommended Download Strategy for Galaxy Game

### Phase 1: Get Sample Data (Start Here)

**Download 1 tile for testing**:

```bash
# Create directory
mkdir -p data/geotiff/samples

# Download single tile (e.g., area around Mt. Everest)
aws s3 cp s3://raster/SRTM_GL1/N27E086.hgt \
    data/geotiff/samples/everest.hgt \
    --endpoint-url https://opentopography.s3.sdsc.edu \
    --no-sign-request

# Convert to GeoTIFF if needed
gdal_translate -co COMPRESS=DEFLATE -co PREDICTOR=2 \
    data/geotiff/samples/everest.hgt \
    data/geotiff/samples/everest.tif
```

### Phase 2: Get Continental Regions

**Download by continent** (more manageable than full global):

```bash
# North America (~15GB)
aws s3 sync s3://raster/SRTM_GL1/ data/geotiff/north_america/ \
    --exclude "*" --include "N*W*" \
    --endpoint-url https://opentopography.s3.sdsc.edu \
    --no-sign-request

# Europe (~8GB)
aws s3 sync s3://raster/SRTM_GL1/ data/geotiff/europe/ \
    --exclude "*" --include "N*E0[0-4]*" \
    --endpoint-url https://opentopography.s3.sdsc.edu \
    --no-sign-request

# Africa (~12GB)
aws s3 sync s3://raster/SRTM_GL1/ data/geotiff/africa/ \
    --exclude "*" --include "*E0[1-4]*" --include "*E00[0-4]*" \
    --endpoint-url https://opentopography.s3.sdsc.edu \
    --no-sign-request
```

### Phase 3: Create Merged Global DEM

**For AI training, you want ONE merged file at lower resolution**:

```bash
# Install GDAL tools
sudo apt-get install gdal-bin  # Ubuntu/Debian
brew install gdal              # Mac

# Merge all tiles into single global mosaic
gdal_merge.py -o data/geotiff/earth_global_30m.tif \
    -co COMPRESS=DEFLATE \
    data/geotiff/**/*.hgt

# Resample to manageable size for AI training (e.g., 3600x1800 = 0.1 degree resolution)
gdalwarp -tr 0.1 0.1 \
    -r bilinear \
    -co COMPRESS=DEFLATE \
    data/geotiff/earth_global_30m.tif \
    data/geotiff/earth_3600x1800.tif

# Or even smaller for initial testing (1800x900 = 0.2 degree)
gdalwarp -tr 0.2 0.2 \
    -r bilinear \
    -co COMPRESS=DEFLATE \
    data/geotiff/earth_global_30m.tif \
    data/geotiff/earth_1800x900.tif
```

---

## 🛠️ Processing GeoTIFF for Galaxy Game

### Step 1: Read GeoTIFF in Ruby

```ruby
# Gemfile
gem 'rgeo-geojson'
gem 'ffi-gdal'  # Ruby bindings for GDAL

# Usage
require 'gdal'

class GeoTIFFReader
  def read_elevation(filepath)
    dataset = GDAL::Dataset.open(filepath, 'r')
    band = dataset.get_raster_band(1)  # Elevation is typically band 1
    
    width = dataset.raster_x_size
    height = dataset.raster_y_size
    
    # Read all elevation data
    elevation_data = band.read_array(0, 0, width, height)
    
    # Get geotransform (lat/lon bounds)
    geotransform = dataset.get_geo_transform
    
    {
      width: width,
      height: height,
      elevation: elevation_data,
      bounds: {
        min_lon: geotransform[0],
        max_lat: geotransform[3],
        pixel_width: geotransform[1],
        pixel_height: geotransform[5]
      }
    }
  ensure
    dataset&.close
  end
end
```

### Step 2: Normalize Elevation to 0-1 Range

```ruby
class ElevationNormalizer
  def normalize(geotiff_data)
    elevations = geotiff_data[:elevation].flatten
    
    min_elev = elevations.min
    max_elev = elevations.max
    
    normalized = geotiff_data[:elevation].map do |row|
      row.map do |elev|
        # Normalize to 0-1 range
        (elev - min_elev) / (max_elev - min_elev).to_f
      end
    end
    
    {
      elevation: normalized,
      width: geotiff_data[:width],
      height: geotiff_data[:height],
      original_range: { min: min_elev, max: max_elev }
    }
  end
end
```

### Step 3: Extract Training Patterns

```ruby
class GeoTIFFPatternExtractor
  def extract_patterns(normalized_data)
    {
      elevation_distribution: calculate_distribution(normalized_data[:elevation]),
      coastline_patterns: detect_coastlines(normalized_data[:elevation]),
      mountain_chains: detect_mountain_ranges(normalized_data[:elevation]),
      slope_gradients: calculate_slopes(normalized_data[:elevation])
    }
  end
  
  private
  
  def calculate_distribution(elevation)
    flat = elevation.flatten
    
    # Calculate histogram
    bins = 20
    histogram = Array.new(bins, 0)
    
    flat.each do |elev|
      bin = [(elev * bins).to_i, bins - 1].min
      histogram[bin] += 1
    end
    
    {
      histogram: histogram,
      mean: flat.sum / flat.size.to_f,
      median: flat.sort[flat.size / 2],
      std_dev: calculate_std_dev(flat)
    }
  end
  
  def detect_coastlines(elevation)
    # Find transitions from land (> 0.0) to water (== 0.0)
    coastline_tiles = []
    
    elevation.each_with_index do |row, y|
      row.each_with_index do |elev, x|
        # Check neighbors
        neighbors = get_neighbors(elevation, x, y)
        
        # If this is land but has water neighbor = coastline
        if elev > 0.0 && neighbors.any? { |n| n == 0.0 }
          coastline_tiles << [x, y]
        end
      end
    end
    
    {
      count: coastline_tiles.size,
      fractal_dimension: calculate_fractal_dimension(coastline_tiles)
    }
  end
end
```

---

## 📊 File Sizes Reference

| Resolution | Coverage | File Size | Download Time (100 Mbps) |
|------------|----------|-----------|--------------------------|
| 30m (1") | Single tile (1°×1°) | ~25 MB | 2 seconds |
| 30m (1") | North America | ~15 GB | 20 minutes |
| 30m (1") | Global | ~150 GB | 3.5 hours |
| 90m (3") | Global | ~17 GB | 23 minutes |
| 0.1° (~11km) | Global (3600×1800) | ~100 MB | 8 seconds |
| 0.2° (~22km) | Global (1800×900) | ~25 MB | 2 seconds |

**Recommendation**: Start with 1800×900 resampled global DEM (~25MB) for initial AI training

---

## 🚀 Quick Start Commands

### Option A: Quick Test (Single Tile)

```bash
# Download Everest region
mkdir -p data/geotiff
aws s3 cp s3://raster/SRTM_GL1/N27E086.hgt data/geotiff/ \
    --endpoint-url https://opentopography.s3.sdsc.edu \
    --no-sign-request
```

### Option B: Global Low-Resolution (For AI Training)

```bash
# Download pre-resampled global DEM (you'll need to create this)
# OR download tiles and merge yourself:

# 1. Download all tiles (150GB - run overnight)
aws s3 sync s3://raster/SRTM_GL1/ data/geotiff/srtm_raw/ \
    --endpoint-url https://opentopography.s3.sdsc.edu \
    --no-sign-request

# 2. Merge to low-res global
gdal_merge.py -o data/geotiff/earth_merged.tif data/geotiff/srtm_raw/*.hgt
gdalwarp -tr 0.2 0.2 -r bilinear data/geotiff/earth_merged.tif data/geotiff/earth_1800x900.tif
```

---

## 🎯 Recommended Workflow for Galaxy Game

1. **Week 1**: Download single test tile, verify processing works
2. **Week 2**: Download North America region, extract patterns
3. **Week 3**: Download global 90m data, create merged low-res DEM
4. **Week 4**: Run full AI pattern extraction, use for planet generation

**Storage Requirements**:
- Test: 25 MB
- Continental: 15 GB
- Global (full res): 150 GB
- Global (AI training res): 100 MB

**Start with the 100 MB resampled version for initial development!**

---

## 📚 Additional Resources

- **GDAL Documentation**: https://gdal.org/
- **SRTM Data Guide**: https://www.usgs.gov/centers/eros/science/usgs-eros-archive-digital-elevation-shuttle-radar-topography-mission-srtm
- **OpenTopography**: https://opentopography.org/
- **GeoTIFF Spec**: https://www.ogc.org/standard/geotiff/

---

## 🎓 Next Steps After Download

Once you have GeoTIFF data:

1. **Extract patterns** (coastlines, mountains, elevation distribution)
2. **Save patterns** to JSON (data/ai_patterns/geotiff_earth.json)
3. **Use patterns** in PlanetaryMapGenerator
4. **Generate maps** for procedural planets that feel Earth-like!

The AI doesn't need the raw 30m data - just the learned PATTERNS from it! 🎯
