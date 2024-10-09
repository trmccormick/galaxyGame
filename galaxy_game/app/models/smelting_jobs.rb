class smelting_jobs < ApplicationRecord
  belongs_to :smelter
  belongs_to :resource
  validates :input_materials, presence: true

  def process_materials(resource)
    input_materials.each do |material, amount|
      resource.add_material(material, amount)
    end
  end
end