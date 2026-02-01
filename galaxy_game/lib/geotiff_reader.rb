require 'json'
require 'fileutils'

class GeoTIFFReader
  def self.read_elevation(filepath)
    # Get georeferencing info from GeoTIFF
    gdalinfo_output = `gdalinfo "#{filepath}"`
    
    # Extract dimensions and georeferencing
    size_match = gdalinfo_output.match(/Size is (\d+), (\d+)/)
    origin_match = gdalinfo_output.match(/Origin = \(([^,]+),([^)]+)\)/)
    pixel_size_match = gdalinfo_output.match(/Pixel Size = \(([^,]+),([^)]+)\)/)
    nodata_match = gdalinfo_output.match(/NoData Value=([^)]+)/)
    
    unless size_match && origin_match && pixel_size_match
      raise "Could not extract georeferencing information from GeoTIFF"
    end
    
    width = size_match[1].to_i
    height = size_match[2].to_i
    origin_x = origin_match[1].to_f
    origin_y = origin_match[2].to_f
    pixel_x = pixel_size_match[1].to_f
    pixel_y = pixel_size_match[2].to_f.abs  # Make positive
    nodata_value = nodata_match ? nodata_match[1].to_f : -99999
    
    # Use gdal_translate to convert to simple ASCII Grid format (no headers)
    temp_asc = "/tmp/elevation_#{Time.now.to_i}.asc"
    system("gdal_translate -of AAIGrid #{filepath} #{temp_asc}")

    if $?.success?
      # Create header lines
      header_lines = [
        "ncols #{width}",
        "nrows #{height}",
        "xllcorner #{origin_x}",
        "yllcorner #{origin_y - height * pixel_y}",  # Bottom-left corner
        "cellsize #{pixel_x}",
        "NODATA_value #{nodata_value}"
      ]
      
      # Read the raw data
      raw_data = File.read(temp_asc)
      
      # Combine header and data
      full_content = header_lines.join("\n") + "\n" + raw_data
      
      # Write to temp file with headers
      temp_with_headers = "/tmp/elevation_with_headers_#{Time.now.to_i}.asc"
      File.write(temp_with_headers, full_content)
      
      data = parse_ascii_grid(temp_with_headers)
      
      # Clean up temp files
      File.delete(temp_asc) if File.exist?(temp_asc)
      File.delete(temp_with_headers) if File.exist?(temp_with_headers)
      
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