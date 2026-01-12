class LocationService
    def initialize(location)
      @location = location
      @resource_richness = load_location_resources
    end
  
    def resource_richness
      @resource_richness
    end
  
    def resource_amount(resource_name)
      @resource_richness[resource_name] || 0
    end
  
    private
  
    def load_location_resources
        geosphere = Geosphere.find_by(celestial_body_id: @location.id)
      
        if geosphere
          materials = {}
          
          # Assuming resources is an association on Geosphere that contains the materials
          geosphere.resources.each do |resource|
            materials[resource.name] = {
              mass: resource.mass,
              # You can include additional attributes from the resource as needed
            }
          end
      
          materials
        else
          {}  # Return an empty hash if no geosphere is found for the location
        end
    end
  end