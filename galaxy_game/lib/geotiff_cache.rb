require 'json'
require 'fileutils'
require 'digest'

class GeoTIFFCache
  CACHE_DIR = Rails.root.join('app/data/ai_manager/cache')

  def self.get_or_process(source_file, &block)
    cache_key = generate_cache_key(source_file)
    cache_file = CACHE_DIR.join("#{cache_key}.json")

    if File.exist?(cache_file) && !stale?(cache_file)
      Rails.logger.info "Loading cached GeoTIFF data for #{File.basename(source_file)}"
      data = JSON.parse(File.read(cache_file))
      # Convert string keys to symbols for consistency
      symbolize_keys(data)
    else
      Rails.logger.info "Processing GeoTIFF data for #{File.basename(source_file)} (this may take a minute)"
      data = block.call

      # Cache the result
      FileUtils.mkdir_p(CACHE_DIR)
      File.write(cache_file, JSON.pretty_generate(data))

      data
    end
  end

  private

  def self.generate_cache_key(filepath)
    # Use file path and modification time for cache key
    mtime = File.mtime(filepath).to_i
    basename = File.basename(filepath, '.*')
    Digest::MD5.hexdigest("#{basename}_#{mtime}")
  end

  def self.stale?(cache_file)
    # Consider cache stale if older than 24 hours
    # In production, you might want different logic
    File.mtime(cache_file) < Time.now - 24 * 60 * 60
  end

  def self.symbolize_keys(obj)
    case obj
    when Hash
      obj.transform_keys(&:to_sym).transform_values { |v| symbolize_keys(v) }
    when Array
      obj.map { |v| symbolize_keys(v) }
    else
      obj
    end
  end
end

class PatternCache
  CACHE_DIR = Rails.root.join('app/data/ai_manager/cache')

  def self.get_or_generate(pattern_type, source_data, &block)
    cache_key = generate_pattern_key(pattern_type, source_data)
    cache_file = CACHE_DIR.join("#{pattern_type}_#{cache_key}.json")

    if File.exist?(cache_file)
      Rails.logger.info "Loading cached #{pattern_type} patterns"
      JSON.parse(File.read(cache_file))
    else
      Rails.logger.info "Generating #{pattern_type} patterns"
      patterns = block.call

      # Add metadata
      patterns['metadata'] ||= {}
      patterns['metadata'].merge!(
        'cached_at' => Time.now.iso8601,
        'pattern_type' => pattern_type,
        'cache_key' => cache_key
      )

      # Cache the result
      FileUtils.mkdir_p(CACHE_DIR)
      File.write(cache_file, JSON.pretty_generate(patterns))

      patterns
    end
  end

  private

  def self.generate_pattern_key(pattern_type, source_data)
    # Create a key based on pattern type and source data characteristics
    metadata = source_data['metadata'] || source_data[:metadata]
    elevation_size = source_data['elevation'] ? source_data['elevation'].flatten.size : source_data[:elevation].flatten.size
    
    case pattern_type
    when 'elevation'
      "elev_#{metadata['source'] || metadata[:source]}_#{elevation_size}"
    when 'coastline'
      "coast_#{metadata['source'] || metadata[:source]}_#{elevation_size}"
    when 'mountain'
      "mnt_#{metadata['source'] || metadata[:source]}_#{elevation_size}"
    else
      "#{pattern_type}_#{Time.now.to_i}"
    end
  end
end