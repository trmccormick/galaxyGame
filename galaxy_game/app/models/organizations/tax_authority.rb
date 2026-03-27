module Organizations
  class TaxAuthority < BaseOrganization
    # We use a singleton pattern for the global tax authority.
    
    class << self
      cattr_accessor :instance, default: nil

      def instance
        @instance ||= find_or_create_by!(name: 'Galactic Commerce Commission Tax Authority', identifier: 'GCC-TAX')
      end
    end
    
    # Tax Authorities do not pay tax
    def tax_rate
      0.0
    end
  end
end