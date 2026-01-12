module FactoryHelpers
  def generate_identifier
    [*('A'..'Z')].sample(rand(2..4)).join + '-' + rand(100..999999).to_s
  end
end