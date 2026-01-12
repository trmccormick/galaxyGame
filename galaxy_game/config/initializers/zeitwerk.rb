# config/initializers/zeitwerk.rb

# Ignore directories that don't follow Ruby naming conventions
Rails.autoloaders.main.ignore(
  Rails.root.join('app/sample_test_scripts'),
  # Add other paths to ignore as needed
)

# Optional: Configure custom inflection rules if needed
Rails.autoloaders.main.inflector.inflect(
  "ai_manager" => "AiColonyManager",
  "api" => "API",
  "json" => "JSON"
)