module Financial
  class BondRepayment < ApplicationRecord
    belongs_to :bond
    belongs_to :currency
    # Optionally, link to a transaction or item/goods transfer

    # amount: decimal
    # description: string (e.g. "Paid with 1000 LOX", "Paid 5000 USD", etc.)
  end
end