# Ensure the legacy all-caps constant is available for Zeitwerk/autoloading
Rails.application.config.to_prepare do
  begin
    require_dependency Rails.root.join('app', 'services', 'logistics', 'isru_capability_manager').to_s
  rescue LoadError
    # ignore if file not present
  end

  if defined?(Logistics::IsruCapabilityManager) && !defined?(Logistics::ISRUCapabilityManager)
    Logistics.const_set('ISRUCapabilityManager', Logistics::IsruCapabilityManager)
  end
end
