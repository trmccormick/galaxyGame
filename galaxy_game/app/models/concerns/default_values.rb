module DefaultValues
  extend ActiveSupport::Concern

  included do
    after_initialize :set_default_values, if: :new_record?
  end

  private

  def set_default_values
    self.class::DEFAULT_VALUES.each do |attribute, value|
      send("#{attribute}=", value) if send(attribute).nil?
    end
  end
end