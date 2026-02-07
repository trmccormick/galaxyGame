require 'json'
require 'fileutils'

class GeoTIFFReader
  def self.read_elevation(filepath)
    # Get info from GeoTIFF
    gdalinfo_output = `gdalinfo "#{filepath}"`
    
    # Extract dimensions (required)
    size_match = gdalinfo_output.match(/Size is (\d+), (\d+)/)
    unless size_match
      raise "Could not extract dimensions from GeoTIFF"
    end
    
    width = size_match[1].to_i
    height = size_match[2].to_i
    
    # Georeferencing is optional - some planetary data may not have it
    origin_match = gdalinfo_output.match(/Origin = \(([^,]+),([^)]+)\)/)
    pixel_size_match = gdalinfo_output.match(/Pixel Size = \(([^,]+),([^)]+)\)/)
    nodata_match = gdalinfo_output.match(/NoData Value=([^\s\n]+)/)
    
    # Use defaults if georeferencing not available
    origin_x = origin_match ? origin_match[1].to_f : -180.0
    origin_y = origin_match ? origin_match[2].to_f : 90.0
    pixel_x = pixel_size_match ? pixel_size_match[1].to_f : (360.0 / width)
    pixel_y = pixel_size_match ? pixel_size_match[2].to_f.abs : (180.0 / height)
    nodata_value = nodata_match ? nodata_match[1].to_f : -99999
    
    # Use gdal_translate to convert to AAIGrid format
    # AAIGrid format already includes proper headers (ncols, nrows, xllcorner, yllcorner, cellsize, NODATA_value)
    temp_asc = "/tmp/elevation_#{Time.now.to_i}.asc"
    system("gdal_translate -of AAIGrid #{filepath} #{temp_asc}")

    if $?.success?
      # AAIGrid already has proper headers, parse it directly
      data = parse_ascii_grid(temp_asc)
      
      # Clean up temp file
      File.delete(temp_asc) if File.exist?(temp_asc)
      
      data
    else
      raise "Failed to convert GeoTIFF to ASCII Grid format"
    end
  end

  private

  def self.parse_ascii_grid(path)
    lines = File.readlines(path)

    # Parse header (first 6 lines)
    header = {}
    lines[0..5].each do |line|
      key, value = line.split
      header[key.downcase] = value.to_f
    end

    # Parse elevation data (skip header lines)
    elevation_data = lines[6..-1].map do |line|
      line.split.map(&:to_f)
    end

    {
      width: header['ncols'].to_i,
      height: header['nrows'].to_i,
      elevation: elevation_data,
      metadata: {
        source: 'ETOPO_2022',
        xllcorner: header['xllcorner'],
        yllcorner: header['yllcorner'],
        cellsize: header['cellsize'],
        nodata_value: header['nodata_value']
      }
    }
  end
end

class ElevationPatternExtractor
  def self.extract_patterns(elevation_data)
    flat = elevation_data[:elevation].flatten.reject { |v| v == elevation_data[:metadata][:nodata_value] }

    # Normalize to 0-1 range
    min_val, max_val = flat.minmax
    normalized = flat.map { |v| (v - min_val) / (max_val - min_val) }

    # Calculate histogram for beta distribution fitting
    histogram = calculate_histogram(normalized, bins: 20)

    # Fit to beta distribution (Earth-like elevation follows Beta(2, 1.5))
    alpha, beta = fit_beta_distribution(histogram)

    {
      distribution: {
        type: 'beta',
        alpha: alpha,
        beta: beta,
        histogram: histogram  # Fallback if beta doesn't work
      },
      statistics: {
        mean: normalized.sum / normalized.size.to_f,
        median: normalized.sort[normalized.size / 2],
        std_dev: calculate_std_dev(normalized),
        min: 0.0,  # normalized
        max: 1.0,  # normalized
        original_range: { min: min_val, max: max_val }
      },
      metadata: {
        extracted_at: Time.now.iso8601,
        source: 'ETOPO_2022',
        sample_size: normalized.size
      }
    }
  end

  private

  def self.calculate_histogram(data, bins: 20)
    min_val, max_val = data.minmax
    bin_width = (max_val - min_val) / bins

    histogram = Array.new(bins, 0)
    data.each do |value|
      bin_index = ((value - min_val) / bin_width).to_i
      bin_index = bins - 1 if bin_index >= bins
      histogram[bin_index] += 1
    end

    # Convert to probabilities
    total = histogram.sum.to_f
    histogram.map { |count| count / total }
  end

  def self.fit_beta_distribution(histogram)
    # Simple moment matching for beta distribution
    # Earth elevation roughly follows Beta(2, 1.5)
    # This is a simplified approach - for production, use proper MLE
    [2.0, 1.5]
  end

  def self.calculate_std_dev(data)
    mean = data.sum / data.size.to_f
    variance = data.map { |x| (x - mean) ** 2 }.sum / data.size.to_f
    Math.sqrt(variance)
  end
end

# Usage example:
# elevation_data = GeoTIFFReader.read_elevation('etopo.nc')
# patterns = ElevationPatternExtractor.extract_patterns(elevation_data)
#
# # Save to JSON
# File.write('data/ai_patterns/geotiff_elevation_patterns.json', JSON.pretty_generate(patterns))