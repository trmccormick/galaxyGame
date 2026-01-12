require 'yaml'
require 'json'
require 'pathname'

module Lookup
  class LogisticsLookupService < BaseLookupService
    def self.base_logistics_path
      @base_logistics_path ||= GalaxyGame::Paths::JSON_DATA.join("logistics")
    end

    def find_provider(provider_id)
      load_data_from_path(base_logistics_path, "#{provider_id}.json")
    end

    def all_providers
      load_all_from_directory(base_logistics_path)
    end
  end
end