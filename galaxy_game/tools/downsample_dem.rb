#!/usr/bin/env ruby
# tools/downsample_dem.rb
# Downsample large DEM/GeoTIFF files for game use

require 'fileutils'

class DEMDownsampler
  def initialize(input_file, output_file = nil, target_width: 200, target_height: 100)
    @input_file = input_file
    @output_file = output_file || generate_output_filename
    @target_width = target_width
    @target_height = target_height
  end

  def downsample
    puts "Downsampling #{@input_file} to #{@target_width}x#{@target_height}..."

    # Check if GDAL is available
    unless gdal_available?
      puts "ERROR: GDAL not found. Install with: brew install gdal"
      return false
    end

    # Get input file info
    input_info = get_gdal_info
    return false unless input_info

    puts "Input: #{input_info[:width]}x#{input_info[:height]} pixels"
    puts "Output: #{@target_width}x#{@target_height} pixels"

    # Downsample using GDAL
    cmd = "gdal_translate -outsize #{@target_width} #{@target_height} -r bilinear '#{@input_file}' '#{@output_file}'"
    puts "Running: #{cmd}"

    success = system(cmd)

    if success && File.exist?(@output_file)
      output_size = File.size(@output_file)
      puts "✅ Success! Output file: #{format_bytes(output_size)}"
      puts "   Saved to: #{@output_file}"
      true
    else
      puts "❌ Failed to downsample"
      false
    end
  end

  private

  def gdal_available?
    system("which gdal_translate > /dev/null 2>&1")
  end

  def get_gdal_info
    output = `gdalinfo '#{@input_file}' 2>/dev/null`
    return nil unless $?.success?

    # Extract dimensions
    width_match = output.match(/Size is (\d+), (\d+)/)
    return nil unless width_match

    {
      width: width_match[1].to_i,
      height: width_match[2].to_i
    }
  end

  def generate_output_filename
    base = File.basename(@input_file, '.*')
    ext = File.extname(@input_file)
    "#{base}_#{@target_width}x#{@target_height}#{ext}"
  end

  def format_bytes(bytes)
    units = ['B', 'KB', 'MB', 'GB']
    unit_index = 0
    size = bytes.to_f

    while size >= 1024 && unit_index < units.length - 1
      size /= 1024.0
      unit_index += 1
    end

    "#{size.round(1)} #{units[unit_index]}"
  end
end

# Command line usage
if __FILE__ == $0
  if ARGV.length < 1
    puts "Usage: ruby downsample_dem.rb <input_file> [output_file] [width] [height]"
    puts "Example: ruby downsample_dem.rb mars_dem.tif mars_small.tif 200 100"
    exit 1
  end

  input_file = ARGV[0]
  output_file = ARGV[1]
  width = (ARGV[2] || 200).to_i
  height = (ARGV[3] || 100).to_i

  unless File.exist?(input_file)
    puts "ERROR: Input file '#{input_file}' not found"
    exit 1
  end

  downsampler = DEMDownsampler.new(input_file, output_file, target_width: width, target_height: height)
  success = downsampler.downsample

  exit success ? 0 : 1
end