# Archive Critical Terrain Data Assets

## Problem
GeoTIFF terrain data is irreplaceable once online sources disappear (Titan PNG incident). Current processed files (~140MB) need safe archival before any optimization or deletion attempts.

## Current State
- **Processed Data**: Complete Sol system coverage (Earth, Mars, Venus, Mercury, Luna, Titan, Vesta)
- **Formats**: .tif, .asc.gz, .prj, .aux.xml files at 1800×900 resolution
- **Backup Copies**: 900×450 versions in temp/ directory
- **Risk**: Online NASA sources can disappear, making recreation difficult/impossible

## Required Changes

### Task 1.1: Create Archive Structure
- Create `data/geotiff/archive/` directory
- Copy ALL processed GeoTIFF files to archive location
- Preserve file permissions and timestamps
- Create checksums (SHA256) for data integrity verification

### Task 1.2: Document Sources and Processing
- Create `data/geotiff/archive/README.md` with:
  - Original source URLs for each planet
  - Processing steps and parameters used
  - GDAL commands for recreation
  - Version information and dates
- Document Titan PNG-to-GeoTIFF conversion process

### Task 1.3: Create Restoration Scripts
- `scripts/terrain/restore_[planet].sh` for each body
- Automated recreation from archived data
- Validation steps to ensure data integrity
- Error handling for missing dependencies

### Task 1.4: Test Archive Integrity
- Verify all archived files are readable
- Test restoration scripts on sample data
- Confirm checksums match original files
- Document archive size and structure

## Success Criteria
- All terrain data safely archived with backups
- Complete documentation for recreation from scratch
- Working restoration scripts for each planet
- Archive integrity verified and documented
- Total archive size < 200MB with compression

## Dependencies
- Requires access to current processed GeoTIFF files
- GDAL tools available for validation
- Sufficient disk space for archival copies

## Priority
High - Prevents permanent data loss, enables safe optimization experiments</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/active/archive_critical_terrain_data_assets.md