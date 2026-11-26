# Titan Elevation Data Generation

> **Code Alignment Status:** `PARTIALLY IMPLEMENTED`  
> *Last Audited:* 2026-11-26
> *Audit Summary:* Pipeline for Titan elevation data partially confirmed; retained intermediate files exist.

**Status: PARTIALLY IMPLEMENTED**  
**Scope:** Historical construction and current availability of Titan's elevation data. This page records the known pipeline and evidence without treating retained intermediate files as disposable or declaring an untraced variant canonical.

## Summary

Titan's usable elevation surface was constructed from a Titan topography image and a purpose-built conversion script. This was not a straightforward case of downloading and using a ready-made global DEM. The retained source and intermediate files are part of the work that produced the usable map and must be preserved while their individual roles are understood.

Titan elevation data is present in the local processed dataset and has been delivered to and rendered by the browser. The existence and successful rendering of the data are not in question. The remaining work is to trace the lineage of the different TIFF variants and determine which consumers read which output.

## Known source and conversion script

The repository contains `process_titan_dem.rb`. Its configured input and outputs are:

- Input image: `data/geotiff/raw/titan_topography_pia16848.png`
- Uncompressed intermediate output: `data/geotiff/processed/titan_1800x900.asc`
- Compressed output: `data/geotiff/processed/titan_1800x900.asc.gz`

The script reads the PNG with ChunkyPNG and resamples it to **1800 × 900** pixels using nearest-neighbor sampling when necessary. It treats the red channel as grayscale brightness, normalizes brightness to 0–1, and converts that value into elevation.

### Constructed Titan surface

The script applies a Titan-specific interpretation to the image:

- It identifies the north polar region (60°N–90°N) and south polar region (60°S–90°S) as lake regions.
- Within those polar regions, pixels below the 0.15 brightness threshold are interpreted as methane-lake basins and mapped through a configured negative-depth interval of **−200 m to −50 m**.
- Other pixels are mapped to positive upland elevations in the configured **0 m to 3000 m** interval.
- It writes an ESRI ASCII grid with 1800 columns, 900 rows, a lower-left corner of (−180°, −90°), 0.2° cell size, and −9999 as the NODATA value.
- It gzip-compresses the ASCII grid and deletes the uncompressed `.asc` file after successful compression.

The negative-depth interval is the configured mapping interval; the actual values emitted by the lake branch also depend on the brightness threshold. Do not interpret the configured interval as proof that every value in that interval occurs in the output.

## Retained processing products

The local processed directory contains multiple Titan products, including:

- `titan_1800x900.asc.gz`
- `titan_1800x900.tif`
- `titan_1800x900_centered.tif`
- `titan_1800x900_final.tif`
- Associated TIFF auxiliary XML metadata files

The raw source image is also retained. These files represent a history of the work to construct and refine a usable Titan elevation map. Their names alone do not establish the exact chronology, transformations, or which variant is authoritative for each consumer.

**Preservation rule:** Do not delete, rename, overwrite, regenerate, or consolidate Titan source/intermediate/final products as part of routine cleanup. First trace their provenance and consumer relationships, then document any proposed change for owner review.

## Evidence that Titan elevation is available and rendered

The owner-provided runtime inspection established that the development container can see the processed GeoTIFF directory and the Titan products listed above.

Owner-provided browser console output shows terrain data arriving for Titan with elevation present. The browser reports:

- Elevation range approximately **−199.211 m to 3000 m**
- A rendered **90 × 45** Titan elevation grid
- Hydrosphere rendering active
- No biome grid supplied in that payload; the renderer therefore displays the elevation heightmap without a biome overlay

This is runtime evidence that Titan elevation is being delivered and rendered. It is separate from the source-code lookup described below. The absence of a biome grid in those logs does not mean the elevation data is missing.

## Source-code lookup discrepancy

At code snapshot `658240a67330d7e3d218931325ceecdb53cddcf4` (2026-11-16 UTC), `AIManager::PlanetaryMapGenerator#load_planet_specific_elevation` maps Titan to:

```text
titan_1800x900_final.asc.gz
```

The method resolves files under:

```text
Rails.root/app/data/geotiff/processed/
```

However, the retained processing script writes `titan_1800x900.asc.gz`, and the owner-provided runtime directory listing contains that non-`final` filename but not `titan_1800x900_final.asc.gz`.

This is a **lookup/output naming inconsistency in that specific method**. It does not establish that Titan elevation is absent, that Titan cannot render, or that this method is the code path responsible for the browser payload observed in the current runtime. Do not rename or copy files to make the names match until the actual runtime data path and the roles of the retained TIFF variants have been traced.

## Development-container path evidence

The standard `docker-compose.dev.yml` configuration binds host `./data/geotiff` to `/home/galaxy_game/app/data/geotiff`, matching the path used by the generator method. The owner ran a container directory listing successfully and confirmed that the processed directory and Titan files are visible inside the development container.

Other Compose configurations were observed not to have the same explicit GeoTIFF bind. That configuration difference should be treated separately; it is not evidence that the standard development environment lacks the data.

## Open provenance questions

These are investigation items, not assumptions that the current data is defective:

1. Trace the original `titan_topography_pia16848.png` source and document its provenance and geographic coverage.
2. Identify the exact transformation and chronology represented by each retained Titan TIFF, including the centered and final variants.
3. Establish whether the ASCII grid was derived directly from the PNG by `process_titan_dem.rb`, from one of the TIFF products, or through additional processing not yet located.
4. Identify which backend service or model path supplies the Titan elevation payload observed by the browser.
5. Determine whether `load_planet_specific_elevation` is invoked for Titan in the relevant Map Studio flow, and whether its filename mapping is stale or serves a separate path.
6. Record which files are canonical inputs for each consumer only after those relationships are verified.

## Verification boundaries

- **Source inspected:** `process_titan_dem.rb` and `galaxy_game/app/services/ai_manager/planetary_map_generator.rb`.
- **Runtime evidence supplied by owner:** processed-directory listing from the development container and browser logs showing Titan elevation delivery and rendering.
- **Not yet established:** complete TIFF lineage, exact consumer of each variant, and the runtime invocation relationship between the browser's Titan payload and `load_planet_specific_elevation`.
- **No data changes:** this research did not modify, regenerate, move, rename, overwrite, or delete any planetary elevation files.
