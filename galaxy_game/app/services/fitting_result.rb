class FittingResult
  attr_accessor :success, :errors, :installed_items, :fitted, :missing

  def initialize
    @success = true
    @errors = []
    @installed_items = []
    @fitted = []
    @missing = []
  end

  def add_error(msg)
    @errors << msg
    @success = false
  end

  def success?
    @success
  end
end