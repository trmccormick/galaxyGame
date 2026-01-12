module Lookup
  class RigLookupService < BaseLookupService
    BASE_PATH = GalaxyGame::Paths::RIGS_PATH

    def initialize
      super
      @rigs = load_rigs unless Rails.env.test?
      @cache = {}
    end

    def find_rig(rig_type)
      return @cache[rig_type] if @cache[rig_type]

      query = rig_type.to_s.downcase
      load_rigs.each do |rig|
        next unless rig.is_a?(Hash)
        # Match by id
        return @cache[rig_type] = rig if rig['id']&.downcase == query
        # Match by aliases
        if rig['aliases'].is_a?(Array) && rig['aliases'].map(&:downcase).include?(query)
          return @cache[rig_type] = rig
        end
      end
      nil
    end

    def load_rigs
      files = Dir.glob(BASE_PATH.join('**', '*_data.json'))
      files.map do |file|
        begin
          JSON.parse(File.read(file))
        rescue => e
          Rails.logger.error("Error loading rig file #{file}: #{e.message}")
          nil
        end
      end.compact
    end
  end
end