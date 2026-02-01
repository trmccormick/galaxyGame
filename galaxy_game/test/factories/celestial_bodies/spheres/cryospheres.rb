FactoryBot.define do
  factory :celestial_bodies_spheres_cryosphere, class: 'CelestialBodies::Spheres::Cryosphere' do
    celestial_body { nil }
    thickness { 1.5 }
    composition { "" }
    artificial { false }
    shell_type { "MyString" }
  end
end
