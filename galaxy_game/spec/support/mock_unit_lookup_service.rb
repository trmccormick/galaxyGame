class MockUnitLookupService
  def find_unit(unit_name)
    {
      'storage_unit' => {
        'name' => 'Storage Unit',
        'type' => 'storage',
        'storage_capacity' => 1000,
        'storage_types' => ['liquid', 'solid', 'gas'],
        'operational_data' => {
          'capacity' => 1000,
          'resources' => {
            'stored' => {}
          }
        }
      }
    }[unit_name.downcase.tr(' ', '_')] || {}
  end
end