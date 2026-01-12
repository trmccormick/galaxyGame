service = Lookup::UnitLookupService.new; puts "Loaded units: #{service.instance_variable_get(:@units).size}"; puts "First unit: #{service.instance_variable_get(:@units).first&.slice("id", "name")}"
