module Organizations
  class TaxAuthority < BaseOrganization
    default_scope { where(organization_type: :tax_authority) }

    class << self
      def reset_instance!
        @instance = nil
      end

      def instance
        @instance ||= find_or_create_by!(
          name: 'Galactic Commerce Commission Tax Authority',
          identifier: 'GCC-TAX',
          organization_type: :tax_authority
        )
      end
    end

    def tax_rate
      0.0
    end
  end
end