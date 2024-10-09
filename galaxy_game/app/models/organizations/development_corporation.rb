# app/models/organization/development_corporation.rb
module Organizations
    class DevelopmentCorporation < BaseOrganization
        # Associations
        has_many :settlements, class_name: 'Units::Settlement', as: :owner
        has_many :outposts, class_name: 'Units::Outpost', as: :owner
        has_many :spaceships, class_name: 'Units::Spaceship', as: :owner
        has_many :base_units, as: :owner
        has_many :research_projects, class_name: 'Research::ResearchProject', as: :sponsor
        has_many :researchers, class_name: 'Research::Researcher', as: :employer
        has_many :materials, class_name: 'CelestialBodies::Material', as: :owner
        has_many :resources, class_name: 'CelestialBodies::Resource', as: :owner
        has_many :celestial_bodies, class_name: 'CelestialBodies::CelestialBody', as: :owner
        has_many :researches, class_name: 'Research::Research', as: :owner

        # Attributes
        attr_accessor :name, :resources, :projects, :profits, :tax_rate

        def initialize(name)
            @name = name
            @resources = []
            @projects = []
            @profits = 0
            @tax_rate = 0
        end

        def fund_project(project)
            @projects << project
            puts "#{name} is funding project: #{project.name}"
        end

        def generate_profit(amount)
            @profits += amount
            puts "#{name} has generated a profit of #{amount} credits."
        end

        def invest_in_research(research)
            @researches << research
            puts "#{name} is investing in research: #{research.name}"
        end

        def manage_resources
            # Logic for resource extraction and distribution
            puts "#{name} is managing resources."

            # Extract resources from settlements
            settlements.each do |settlement|
                settlement.inventories.each do |inventory|
                    resources << inventory.resource
                    inventory.amount = 0 # Reset inventory
                end
            end

            # Distribute resources to outposts
            distribute_resources(outposts)

            # Distribute profits to all entities
            distribute_profits(settlements)
            distribute_profits(outposts)
            distribute_profits(spaceships)
            distribute_profits(research_projects)
            distribute_profits(researchers)
            distribute_profits(materials)
            distribute_profits(resources)
            distribute_profits(celestial_bodies)
            distribute_profits(researches)

            puts "#{name} has managed resources and distributed profits."
        end

        private

        def distribute_resources(entities)
            entities.each do |entity|
                resources.each do |resource|
                    entity.inventories.create(resource: resource, amount: 100)
                end
            end
        end

        def distribute_profits(entities)
            entities.each do |entity|
                entity.resources << resources
            end
            self.profits = 0 # Reset profits
            puts "#{name} has distributed profits to #{entities.class.name.downcase}."
        end
    end
end