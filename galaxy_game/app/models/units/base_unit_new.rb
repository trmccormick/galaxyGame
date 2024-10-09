# app/models/base_unit.rb
class BaseUnit < ApplicationRecord
    belongs_to :outpost, optional: true
    belongs_to :colony, optional: true
    belongs_to :city, optional: true
    has_many :resources, through: :outpost
    has_many :resources, through: :colony
    has_many :resources, through: :city

    include Housing
    include Storage
    
    attr_accessor :name, :base_materials, :operating_requirements, :input_resources, :output_resources
  
    def initialize(name, base_materials, operating_requirements, input_resources, output_resources)
      @name = name
      @base_materials = base_materials
      @operating_requirements = operating_requirements
      @input_resources = input_resources
      @output_resources = output_resources
    end
  
    # Common methods for units
    def operate
      consume_resources
      produce_resources
    end
  
    private
  
    def consume_resources
      input_resources.each do |resource, amount|
        puts "#{name} is consuming #{amount} of #{resource}."
      end
      puts "#{name} is consuming #{operating_requirements[:power]} kWh of power."
    end
  
    def produce_resources
      output_resources.each do |resource, amount|
        puts "#{name} is producing #{amount} of #{resource}."
      end
    end

    # should harvest resources from the current celestial body
    # def harvest_resources
    #     base_materials.each do |resource, amount|
    #         puts "#{name} is harvesting #{amount} of #{resource}."
    #     end
    # end
  end
  