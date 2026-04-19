# Loads a cargo manifest JSON file for settlement deployment
class CargoManifestLoader
  MISSIONS_PATH = Rails.root.join('app', 'data', 'json-data', 'missions')

  def self.load(manifest_name)
    path = MISSIONS_PATH.join("{manifest_name}.json")
    raise "Cargo manifest not found: #{path}" unless File.exist?(path)
    JSON.parse(File.read(path))
  end
end
