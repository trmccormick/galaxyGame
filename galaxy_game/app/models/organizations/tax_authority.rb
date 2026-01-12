module Organizations
  class TaxAuthority < BaseOrganization
    # We use a singleton pattern for the global tax authority.
    
    def self.instance
      # Ensures there is only one Tax Authority record, created if necessary.
      # Assumes a BaseOrganization exists with `find_or_create_by!`
      begin
        find_or_create_by!(name: 'Galactic Commerce Commission Tax Authority', identifier: 'GCC-TAX')
      rescue ActiveRecord::StatementInvalid => e
        # Database not ready or table doesn't exist
        Rails.logger.warn "TaxAuthority.instance failed: #{e.message}. Database may not be initialized."
        nil
      end
    end
    
    # Tax Authorities do not pay tax
    def tax_rate
      0.0
    end
  end
end