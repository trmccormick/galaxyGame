require 'bigdecimal'
require 'psych'

# Allow BigDecimal for YAML deserialization in Psych safe_load (Rails 7+/Psych 4+)
if Psych.respond_to?(:safe_load_set)
  Psych.safe_load_set permitted_classes: [BigDecimal]
end