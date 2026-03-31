Task File: BaseStructure Unit Slot Management
Target: 6 failures in unit install/uninstall/build_recommended_units
Files: spec/models/structures/base_structure_spec.rb:155,162,178,188,206 + spec/models/craft/base_craft_spec.rb:252,262

Failures
text
base_structure_spec.rb:
155: install_unit installs a unit if slot is available → FAIL  
162: install_unit fails if no slot is available → FAIL
178: uninstall_unit removes an installed unit → FAIL  
188: uninstall_unit fails for units not attached → FAIL
206: build_recommended_units builds the recommended units → FAIL

base_craft_spec.rb:
252: player construction allows installing units → FAIL
262: player construction allows uninstalling units → FAIL
Diagnostic Commands
bash
# Current slot logic
grep -n "install_unit\|uninstall_unit\|slots\|has_units" app/models/structures/base_structure.rb app/models/concerns/has_units.rb

# Concern implementation  
grep -n "def install_unit\|def uninstall_unit" app/models/concerns/has_units.rb

# Spec expectations
sed -n '150,210p' spec/models/structures/base_structure_spec.rb
sed -n '250,270p' spec/models/craft/base_craft_spec.rb
Expected Root Cause
HasUnits concern slot checking logic doesn't match BaseStructure/BaseCraft expectations:

Slot availability check failing

Unit attachment state mismatch

build_recommended_units can't find slots

Success Criteria
text
rspec spec/models/structures/base_structure_spec.rb → 0 failures
rspec spec/models/craft/base_craft_spec.rb → 0 failures  
rspec spec/models/ → model suite baseline improves by 6 failures