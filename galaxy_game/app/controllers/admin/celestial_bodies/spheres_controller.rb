# frozen_string_literal: true

module Admin
  module CelestialBodies
    # Admin controller for managing spheres of celestial bodies
    class SpheresController < ApplicationController
      before_action :set_celestial_body
      before_action :set_sphere, only: [:update, :destroy]

      # POST /admin/celestial_bodies/:celestial_body_id/spheres
      def create
        sphere_type = params[:sphere_type]
        sphere_class = sphere_class_for_type(sphere_type)

        if sphere_class.nil?
          render json: { error: "Invalid sphere type: #{sphere_type}" }, status: :unprocessable_entity
          return
        end

        # Check if sphere already exists
        existing_sphere = @celestial_body.send(sphere_type)
        if existing_sphere
          render json: { error: "#{sphere_type.humanize} already exists for this celestial body" }, status: :unprocessable_entity
          return
        end

        sphere = @celestial_body.send("create_#{sphere_type}!", sphere_params_for_type(sphere_type))

        if sphere.persisted?
          render json: {
            success: true,
            sphere: sphere_data_for_response(sphere, sphere_type),
            message: "#{sphere_type.humanize} created successfully"
          }
        else
          render json: { error: sphere.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
      rescue StandardError => e
        render json: { error: "Failed to create sphere: #{e.message}" }, status: :internal_server_error
      end

      # PATCH/PUT /admin/celestial_bodies/:celestial_body_id/spheres/:id
      def update
        sphere_type = params[:sphere_type] || @sphere.class.name.demodulize.underscore
        update_params = sphere_params_for_type(sphere_type)

        if @sphere.update(update_params)
          render json: {
            success: true,
            sphere: sphere_data_for_response(@sphere, sphere_type),
            message: "#{sphere_type.humanize} updated successfully"
          }
        else
          render json: { error: @sphere.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
      rescue StandardError => e
        render json: { error: "Failed to update sphere: #{e.message}" }, status: :internal_server_error
      end

      # DELETE /admin/celestial_bodies/:celestial_body_id/spheres/:id
      def destroy
        sphere_type = @sphere.class.name.demodulize.underscore

        if @sphere.destroy
          render json: {
            success: true,
            message: "#{sphere_type.humanize} deleted successfully"
          }
        else
          render json: { error: "Failed to delete sphere" }, status: :unprocessable_entity
        end
      rescue StandardError => e
        render json: { error: "Failed to delete sphere: #{e.message}" }, status: :internal_server_error
      end

      private

      def set_celestial_body
        @celestial_body = ::CelestialBodies::CelestialBody.find(params[:celestial_body_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Celestial body not found' }, status: :not_found
      end

      def set_sphere
        @sphere = @celestial_body.spheres.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Sphere not found' }, status: :not_found
      end

      def sphere_class_for_type(sphere_type)
        case sphere_type
        when 'atmosphere'
          ::CelestialBodies::Spheres::Atmosphere
        when 'hydrosphere'
          ::CelestialBodies::Spheres::Hydrosphere
        when 'cryosphere'
          ::CelestialBodies::Spheres::Cryosphere
        when 'subsurface_hydrosphere'
          ::CelestialBodies::Spheres::Hydrosphere
        when 'geosphere'
          ::CelestialBodies::Spheres::Geosphere
        when 'biosphere'
          ::CelestialBodies::Spheres::Biosphere
        else
          nil
        end
      end

      def sphere_params_for_type(sphere_type)
        base_params = params.require(:sphere).permit(
          :temperature, :pressure, :shell_type, :artificial,
          :total_liquid_mass, :total_water_mass, :total_atmospheric_mass,
          :total_crust_mass, :total_mantle_mass, :total_core_mass,
          :geological_activity, :habitable, :oxygen_percentage,
          composition: {}, properties: {}, temperature_data: {},
          water_bodies: {}, state_distribution: {}, base_values: {},
          gas_ratios: {}, dust: [:concentration, :particle_size]
        )

        # Add specific validations based on sphere type
        case sphere_type
        when 'atmosphere'
          base_params.merge(params.require(:sphere).permit(:scale_height, :mean_molecular_weight))
        when 'hydrosphere', 'subsurface_hydrosphere'
          base_params.merge(params.require(:sphere).permit(:salinity, :ph_level, :dissolved_oxygen))
        when 'cryosphere'
          base_params.merge(params.require(:sphere).permit(:thickness, :thermal_conductivity, :density))
        when 'geosphere'
          base_params.merge(params.require(:sphere).permit(:stored_volatiles))
        when 'biosphere'
          base_params.merge(params.require(:sphere).permit(:biomass, :species_count, :primary_producers))
        else
          base_params
        end
      end

      def sphere_data_for_response(sphere, sphere_type)
        {
          id: sphere.id,
          type: sphere_type,
          temperature: sphere.temperature,
          pressure: sphere.pressure,
          created_at: sphere.created_at,
          updated_at: sphere.updated_at
        }.tap do |data|
          # Add type-specific data
          case sphere_type
          when 'atmosphere'
            data.merge!(
              total_atmospheric_mass: sphere.total_atmospheric_mass,
              composition: sphere.composition
            )
          when 'hydrosphere', 'subsurface_hydrosphere'
            data.merge!(
              total_liquid_mass: sphere.total_liquid_mass || sphere.total_water_mass,
              composition: sphere.composition
            )
          when 'cryosphere'
            data.merge!(
              thickness: sphere.thickness,
              shell_type: sphere.shell_type,
              properties: sphere.properties
            )
          when 'geosphere'
            data.merge!(
              total_crust_mass: sphere.total_crust_mass,
              total_mantle_mass: sphere.total_mantle_mass,
              total_core_mass: sphere.total_core_mass,
              geological_activity: sphere.geological_activity
            )
          when 'biosphere'
            data.merge!(
              habitable: sphere.habitable,
              biomass: sphere.biomass,
              species_count: sphere.species_count
            )
          end
        end
      end
    end
  end
end