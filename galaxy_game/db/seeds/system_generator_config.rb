SYSTEM_GENERATION = {
  planet_types: {
    terrestrial: {
      mass_range: [0.055, 10.0], # Earth masses
      composition_ranges: {
        rock: [80, 100],
        metal: [0, 20]
      }
    }
  },
  atmosphere_ranges: {
    pressure: [0.0001, 100.0],
    composition_templates: {
      earth_like: {
        'N2' => { range: [75.0, 80.0] },
        'O2' => { range: [19.0, 21.0] }
      }
    }
  }
}