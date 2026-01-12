# lib/tasks/financial_tax_validation.rake

require 'json'
require 'securerandom'

# Reuse the resilient stubbing helper from the previous Rake file
# NOTE: You MUST include or redefine the stub_class_method_resilient helper here!
# For simplicity, we assume it's available or copy/pasted here.

namespace :financial do
  desc "Validates GCC Operational Tax calculation and transaction handling for Corporations."
  task validate_tax_operation: :environment do
    puts "\n=== FINANCIAL VALIDATION: GCC OPERATIONAL TAX CALCULATION ==="
    
    # 1. DEFINE MOCK DATA
    MOCK_TAX_RATE = 0.15
    MOCK_TRANSACTION_VALUE = 2000.00
    MOCK_EXPECTED_TAX = MOCK_TRANSACTION_VALUE * MOCK_TAX_RATE # $300.00

    # 2. Setup Cleanup Routines and State
    cleanup_routines = []
    tax_payment_record = { called: false, organization: nil, amount: nil }
    
    begin
      # 3. STUB: Mock the TransactionManager to capture the tax payment
    
      # Define the mock implementation
      manager_stub_implementation = lambda do |*args, **kwargs|
        # This block will execute instead of the real create_transfer
        tax_payment_record.merge!(
        called: true, 
        organization: kwargs[:from], # Assuming the 'from' account's owner is the organization
        amount: kwargs[:amount]
        )
    
        # Must return a mock object that the calling service expects (the transaction)
        Struct.new(:id).new(SecureRandom.uuid) 
       end
        
       # We stub the class method :create_transfer on Financial::TransactionManager
       cleanup_routines << self.stub_class_method_resilient(
         Financial::TransactionManager, 
        :create_transfer, 
        manager_stub_implementation
       )

      # 4. SETUP: Create the Corporation (which initializes tax_rate to 0.15)
      corporation = Organizations::Corporation.find_or_create_by!(
        name: "Test Tax Corp", identifier: 'TTC-001'
      ) do |c|
        c.operational_data = {
            'resources' => [],
            'projects' => [],
            'profits' => 0,
            'tax_rate' => 0.15 # <--- SET THE TAX RATE TO 15%
        }
      end
      
      puts "✓ Corporation initialized with tax rate: #{corporation.tax_rate}"

      # 5. SETUP Currency - Find the one created in the seeds
      currency = Financial::Currency.find_by!(symbol: 'GCC')      
      
      # 6. EXECUTE: Call the Tax Service (assumed to be available)
      puts "--- Executing Tax Application on $#{MOCK_TRANSACTION_VALUE} ---"
      
      # Fix the typo from GccTaxService to TaxCollectionService
      result = Financial::TaxCollectionService.collect_sales_tax( # NOTE: Also using collect_sales_tax method
        corporation, 
        MOCK_TRANSACTION_VALUE, 
        currency
      )
      
      # 7. VALIDATION
      puts "\n--- VALIDATING RESULTS ---"
      
      check_pass = true

      if result[:success]
        puts "✓ Service execution successful."
      else
        puts "✗ ERROR: Service failed: #{result[:error]}"
        check_pass = false
      end
      
      # A. Validate Tax Amount
      if result[:tax_paid] == MOCK_EXPECTED_TAX
        puts "✓ Tax calculated correctly: Paid $#{'%.2f' % result[:tax_paid]} (Expected $#{'%.2f' % MOCK_EXPECTED_TAX})."
      else
        puts "✗ ERROR: Tax amount mismatch. Found $#{'%.2f' % result[:tax_paid]}, Expected $#{'%.2f' % MOCK_EXPECTED_TAX}."
        check_pass = false
      end
      
      # B. Validate Transaction Recording
      if tax_payment_record[:called] && tax_payment_record[:amount] == MOCK_EXPECTED_TAX
        puts "✓ Tax transaction manager called with correct amount."
      else
        puts "✗ ERROR: Tax transaction manager was not called correctly. State: #{tax_payment_record.inspect}"
        check_pass = false
      end
      
      puts "\n=== Tax Validation Complete. Result: #{check_pass ? 'PASS' : 'FAIL'} ==="
      
    ensure
      # 8. CLEANUP
      corporation.destroy! if defined?(corporation) && corporation.persisted?
      puts "\n[CLEANUP] Restoring original class methods..."
      cleanup_routines.each(&:call)
    end
    
  end
end