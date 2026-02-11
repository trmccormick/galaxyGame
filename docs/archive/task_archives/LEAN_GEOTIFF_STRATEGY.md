# Lean GeoTIFF Strategy - Under 100MB Total

## 🎯 Smart Approach: Pre-Processed, Not Raw Data

**You DON'T need**:
- ❌ 150GB of raw 30m resolution tiles
- ❌ Global coverage at full resolution
- ❌ Every mountain and valley on Earth

**You DO need**:
- ✅ ~25MB resampled global DEM (1800×900 pixels)
- ✅ Pattern extraction code
- ✅ Learned patterns saved to JSON (~1MB)

**Total Storage**: < 100MB (probably < 30MB!)

---

## 📥 Option 1: Download Pre-Made Low-Res Global DEM (EASIEST)

### GEBCO 2024 - Global Ocean & Land Terrain (15 arc-seconds = ~500m resolution)

**Size**: ~450MB for global 15 arc-second (can resample to 50MB)
**Coverage**: Global (including oceans!)
**Format**: NetCDF (easily converted to GeoTIFF)
**Source**: https://www.gebco.net/data_and_products/gridded_bathymetry_data/

**Download**:
```bash
# Download GEBCO 2024 grid (15 arc-second resolution)
wget https://www.bodc.ac.uk/data/open_download/gebco/gebco_2024/geotiff/ -O gebco_2024.tif

# Or get the even smaller 1 arc-minute version (~50MB)
wget https://www.bodc.ac.uk/data/open_download/gebco/gebco_2024_sub_ice_topo/geotiff/ -O gebco_1min.tif
```

**Processing**:
```bash
# Resample to Galaxy Game resolution (1800×900 = 0.2 degrees)
gdalwarp -tr 0.2 0.2 -r bilinear \
    -co COMPRESS=DEFLATE \
    gebco_2024.tif \
    data/geotiff/earth_1800x900.tif

# Result: ~15-25MB file
```

---

## 📥 Option 2: ETOPO 2022 (Global Relief Model) - SMALLEST

**Size**: ~70MB for 1 arc-minute resolution global
**Coverage**: Global land AND ocean
**Format**: NetCDF, GeoTIFF, ASCII
**Source**: NOAA

**Download**:
```bash
# Download ETOPO 2022 (60 arc-second / 1 arc-minute resolution)
# Direct download from NOAA
wget https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO2022/data/60s/60s_surface_elev_netcdf/ETOPO_2022_v1_60s_N90W180_surface.nc \
    -O etopo_2022.nc

# Convert NetCDF to GeoTIFF
gdal_translate -of GTiff \
    -co COMPRESS=DEFLATE \
    NETCDF:"etopo_2022.nc":z \
    data/geotiff/earth_etopo.tif

# Result: ~60MB file already at good resolution for AI training!
```

---

## 📥 Option 3: Direct Download Pre-Processed for Galaxy Game (BEST)

I can provide you with a **pre-processed, ready-to-use** file:

### What I'll Create:

**File**: `earth_training_1800x900.tif`
**Size**: ~20MB
**Resolution**: 1800×900 pixels (0.2° per pixel = ~22km at equator)
**Format**: GeoTIFF, normalized 0-1 elevation
**Coverage**: Global

**Download Commands**:
```bash
# Option A: From a public repo (if you create one)
wget https://github.com/yourusername/galaxy-game-data/releases/download/v1.0/earth_training_1800x900.tif

# Option B: Use existing low-res DEM
# Natural Earth provides a nice 10m resolution raster (~50MB)
wget https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/NE1_HR_LC_SR_W.zip
unzip NE1_HR_LC_SR_W.zip
```

---

## 🛠️ DIY: Create Your Own Small Training DEM

### Step 1: Download SRTM Void-Filled 90m (3 arc-second) - 17GB

This is much smaller than the 30m version:

```bash
# Download 90m resolution instead of 30m (only 17GB vs 150GB)
wget https://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_[01-72]_[01-24].zip

# Or use the CGIAR-CSI pre-processed version (better!)
# They have continent-level tiles:

# Just Africa (1.2GB)
wget https://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/africa.zip

# Just Eurasia (4.5GB)
wget https://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/eurasia.zip
```

### Step 2: Merge and Downsample

```bash
# Unzip downloaded files
unzip africa.zip -d africa/

# Merge tiles
gdal_merge.py -o merged.tif africa/*.tif

# Downsample to training resolution (1800×900)
gdalwarp -tr 0.2 0.2 \
    -r bilinear \
    -co COMPRESS=DEFLATE \
    -co PREDICTOR=2 \
    merged.tif \
    earth_training_1800x900.tif

# Result: ~20-30MB file
# Delete the large originals!
rm -rf africa/ merged.tif
```

---

## 💾 Recommended Storage Strategy

### What to Keep on Disk:

```
data/
├── geotiff/
│   └── earth_1800x900.tif          # 20-30MB - Training DEM
│
├── ai_patterns/
│   ├── geotiff_patterns.json       # 1-2MB - Extracted patterns
│   ├── freeciv_patterns.json       # <1MB - From FreeCiv maps
│   └── civ4_patterns.json          # <1MB - From Civ4 maps
│
└── maps/
    ├── freeciv/                    # Keep existing Civ/FreeCiv maps
    └── civ4/                       # Already have these!

Total: ~50MB maximum
```

### Pattern Extraction (One-Time Process):

```ruby
# 1. Load 20MB GeoTIFF
geotiff = GeoTIFFReader.read('data/geotiff/earth_1800x900.tif')

# 2. Extract patterns
patterns = GeoTIFFPatternExtractor.extract_patterns(geotiff)

# 3. Save to tiny JSON file (~1MB)
File.write('data/ai_patterns/geotiff_patterns.json', patterns.to_json)

# 4. (Optional) Delete the 20MB GeoTIFF - don't need it anymore!
# You now have all the patterns in 1MB JSON
```

**After extraction**: You can delete the GeoTIFF! Keep only the JSON patterns.

**Total persistent storage**: ~5MB of JSON patterns

---

## 🎯 Absolute Minimal Approach (NO Download!)

### Use What You Already Have

You don't even NEED external GeoTIFF if you:

1. **Use FreeCiv maps as-is** for topology patterns
2. **Use Civ4 maps** for strategic patterns
3. **Generate elevation** using multi-octave Perlin noise (you already have this!)

**Why add GeoTIFF at all?**
Only to make coastlines and mountain ranges look more "Earth-like"

**Can you skip it?**
YES! Your current Perlin noise generator is fine for procedural planets!

**When you SHOULD add it**:
- If you want Earth-analog planets to feel realistic
- If players complain maps look "too random"
- If you want marketing screenshots showing "realistic Earth-based generation"

---

## 📊 File Size Comparison

| Source | Resolution | Global Size | After Resample to 1800×900 |
|--------|------------|-------------|---------------------------|
| SRTM 30m | 1 arc-sec | 150GB | 25MB |
| SRTM 90m | 3 arc-sec | 17GB | 20MB |
| ETOPO 2022 | 1 arc-min | 70MB | 15MB (already close!) |
| GEBCO 2024 | 15 arc-sec | 450MB | 20MB |
| Natural Earth 10m | ~10km | 50MB | N/A (raster image, not DEM) |

**Recommendation**: Download **ETOPO 2022** (70MB) → Process to 15MB → Extract patterns to 1MB JSON → Delete original

---

## 🚀 Quick Start (Smallest Approach)

### Total Downloads: ~70MB
### Total Storage After Processing: ~5MB

```bash
# 1. Download ETOPO (70MB)
wget https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO2022/data/60s/60s_surface_elev_netcdf/ETOPO_2022_v1_60s_N90W180_surface.nc

# 2. Convert to GeoTIFF (15MB)
gdal_translate -of GTiff ETOPO_2022_v1_60s_N90W180_surface.nc earth_etopo.tif

# 3. Extract patterns in Ruby (results in 1MB JSON)
ruby scripts/extract_geotiff_patterns.rb

# 4. Delete source files
rm ETOPO_2022_v1_60s_N90W180_surface.nc earth_etopo.tif

# 5. Keep only:
# data/ai_patterns/geotiff_patterns.json (~1MB)
```

---

## 🎓 Alternative: Community-Contributed Patterns

**Even Better Idea**: Ship pre-extracted patterns with the game!

```
# In your Git repo:
data/ai_patterns/
├── earth_geotiff_patterns.json     # You extract once, commit to repo
├── freeciv_learned_patterns.json   # Extract from FreeCiv maps once
└── civ4_learned_patterns.json      # Extract from Civ4 maps once

# Users download your repo = instant access to patterns
# No need for users to download/process GeoTIFF at all!
```

**Size**: ~3-5MB total patterns
**Users download**: 0 bytes (already in repo!)

---

## 💡 My Recommendation

**Don't download anything large!**

**Instead**:

1. Use **ETOPO 2022** (70MB download, one-time)
2. Process to **15MB GeoTIFF**
3. Extract to **1MB JSON patterns**
4. **Delete** ETOPO
5. **Commit patterns to Git**
6. Users never need to download GeoTIFF!

**Total dev storage**: 70MB during processing, 1MB permanent
**Total user storage**: 0MB (patterns in repo)
**Total repo size increase**: 1-2MB

This is WAY more practical than 150GB! 🎯
