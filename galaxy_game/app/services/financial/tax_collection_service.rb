module Financial
  class TaxCollectionService
    
    # Calculates and collects the tax due on a specific sales price.
    def self.collect_sales_tax(seller_organization, price, currency)
      tax_rate = seller_organization.try(:tax_rate) || 0.0
      tax_amount = price * tax_rate

      if tax_amount > 0
        tax_authority = Organizations::TaxAuthority.instance
        seller_account = Financial::Account.find_or_create_for_entity_and_currency(
          accountable_entity: seller_organization,
          currency: currency
        )
        tax_account = Financial::Account.find_or_create_for_entity_and_currency(
          accountable_entity: tax_authority,
          currency: currency
        )
        Financial::TransactionManager.create_transfer(
          from: seller_account,
          to: tax_account,
          amount: tax_amount,
          currency: currency,
          description: "GCC Operational Tax on $#{'%.2f' % price} sale."
        )
        return tax_amount
      else
        return 0.0
      end
    end
  end
end