#!/usr/bin/env ruby

# Simple test script to check material lookup
require 'yaml'
require 'json'
require 'pathname'

# Mock Rails.root for testing
class Rails
  def self.root
    Pathname.new('/Users/tam0013/Documents/git/galaxyGame/galaxy_game')
  end
end

# Mock GalaxyGame::Paths
module GalaxyGame
  module Paths
    JSON_DATA = 'data/json-data'
  end
end

# Include the lookup service
require_relative 'app/services/lookup/material_lookup_service.rb'

begin
  service = Lookup::MaterialLookupService.new
  result = service.find_material('O2')
  puts "O2 lookup result: #{result ? result['name'] : 'not found'}"

  # Also try 'oxygen'
  result2 = service.find_material('oxygen')
  puts "oxygen lookup result: #{result2 ? result2['name'] : 'not found'}"
rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace.join("\n")
end