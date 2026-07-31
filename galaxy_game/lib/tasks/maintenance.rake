namespace :maintenance do
  desc "Refresh material lookup cache (useful for cron scheduling)"
  task refresh_material_cache: :environment do
    puts "🔄 Refreshing material lookup cache..."
    start_time = Time.now
    
    # Reset the cache — forces reload on next find_material() call
    Lookup::MaterialLookupService.reset_cache!
    
    # Trigger cache repopulation by accessing materials_cache
    cache = Lookup::MaterialLookupService.materials_cache
    elapsed = Time.now - start_time
    
    puts "✅ Material cache refreshed in #{elapsed.round(2)}s"
    puts "   Loaded #{cache.size} material entries"
  end

  desc "Refresh all lookup service caches"
  task refresh_all_caches: :environment do
    puts "🔄 Refreshing all lookup service caches..."
    start_time = Time.now
    
    # Material lookup service
    Lookup::MaterialLookupService.reset_cache!
    material_cache = Lookup::MaterialLookupService.materials_cache
    
    # TODO: Add caching to other lookup services
    # - BlueprintLookupService
    # - UnitLookupService  
    # - ModuleLookupService
    # - StructureLookupService
    # - ItemLookupService
    # - CraftLookupService
    # - RigLookupService
    
    puts "✅ All caches refreshed in #{(Time.now - start_time).round(2)}s"
    puts "   - Material cache: #{material_cache.size} entries"
    puts "   ⚠️  Other lookup services need caching implementation"
  end
end

namespace :cache do
  desc "Alias: refresh material cache"
  task refresh: "maintenance:refresh_material_cache"
  
  desc "Alias: refresh all caches"
  task refresh_all: "maintenance:refresh_all_caches"
end
