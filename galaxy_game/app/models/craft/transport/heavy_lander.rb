# app/models/craft/transport/heavy_lander.rb
module Craft
  module Transport
    class HeavyLander < BaseTransport
      include Docking
      include LifeSupport
      include EnergyManagement

      # validates :starship_class, presence: true

      # charging_ports stored in operational_data JSON
      def charging_ports
        operational_data['charging_ports'] ||= []
      end

      def available_charging_ports
        charging_ports.select { |p| !p['occupied'] }
      end

      # Deploy up to `count` robots matching unit_type.
      # If the starship’s inventory held them as items, remove those and
      # create real Unit records attached to the settlement at `location`.
      #
      # @param unit_type [String] exact id (or SQL LIKE pattern if it contains '%')
      # @param count [Integer]
      # @param location [Location::CelestialLocation, Settlement::BaseSettlement]
      # @return [Array<Units::BaseUnit>]
      def deploy_units(unit_type:, count:, location: nil)
        location ||= current_location

        # Resolve the settlement object
        target_settlement =
          if location.is_a?(Settlement::BaseSettlement)
            location
          elsif location.respond_to?(:settlement)
            location.settlement
          else
            raise ArgumentError, "Cannot deploy to #{location.inspect}"
          end

        deployed = []

        # For each item in our inventory matching the unit_type…
        inventory.items
                 .where(name: unit_type)
                 .limit(count)
                 .each do |item|

          ActiveRecord::Base.transaction do
            # remove one from inventory
            item.decrement!(:amount, 1)
            item.destroy if item.amount.zero?

            # create the actual robot unit
            robot = Units::Robot.create!(
              identifier: "#{unit_type}_#{SecureRandom.hex(4)}",
              name: Lookup::UnitLookupService.new.find_unit(unit_type)['name'],
              unit_type: unit_type,
              owner: target_settlement,
              attachable: target_settlement,
              operational_data: Lookup::UnitLookupService.new.find_unit(unit_type).deep_dup
            )

            # schedule its first task
            robot.assign_task(:deploy_from_craft, location: location)

            deployed << robot
          end
        end

        deployed
      end

      # Handle a mission-style effect
      def handle_deploy_effect(effect)
        return unless effect['action'] == 'deploy_unit'
        deploy_units(
          unit_type: effect['unit'],
          count:     effect['count'],
          location:  effect['location']
        )
      end

      # Dock a single robot into a named charging port
      def dock_robot_for_charge(robot, port_name)
        ports = charging_ports
        port  = ports.find { |p| p['name']==port_name && !p['occupied'] }
        return false unless port

        ActiveRecord::Base.transaction do
          robot.attachable = self
          robot.operational_data['charging_port'] = port_name
          robot.save!

          port['occupied'] = true
          write_attribute(:operational_data, operational_data)
          save!
        end
        true
      end

      # Release a robot from its charging port
      def release_robot_from_charge(robot)
        port_name = robot.operational_data.delete('charging_port')
        robot.save!

        port = charging_ports.find { |p| p['name']==port_name }
        port['occupied'] = false if port
        write_attribute(:operational_data, operational_data)
        save!
      end

      # Convenience if you really want CAR-series only:
      def deliver_car_robots_to_surface
        deploy_units(unit_type: 'CAR-%', count: 2)
      end
    end
  end
end
