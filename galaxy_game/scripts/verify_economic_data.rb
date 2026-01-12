#!/usr/bin/env ruby
# Economic Verification Script
# Verifies that units have usd_import_fee and base_cost_eap fields

require_relative '../config/environment'

class EconomicVerifier
  def verify_economic_fields
    puts "Verifying economic fields in unit data..."

    # Load a sample unit using UnitLookupService
    unit_lookup = Lookup::UnitLookupService.new
    unit = unit_lookup.find_unit('basic_computer')

    if unit.nil?
      puts "ERROR: Could not find basic_computer unit"
      return false
    end

    puts "Found unit: #{unit['name']}"

    # Check for usd_import_fee
    usd_fee = unit['usd_import_fee']
    if usd_fee.nil?
      puts "ERROR: usd_import_fee is missing"
      return false
    end

    puts "usd_import_fee: #{usd_fee}"

    # Check for base_cost_eap
    eap_cost = unit['base_cost_eap']
    if eap_cost.nil?
      puts "ERROR: base_cost_eap is missing"
      return false
    end

    puts "base_cost_eap: #{eap_cost}"

    # Simulate a purchase calculation
    total_cost = usd_fee + eap_cost
    puts "Simulated total cost: #{total_cost}"

    puts "Economic verification PASSED"
    true
  end
end

# Run the verifier
if __FILE__ == $0
  verifier = EconomicVerifier.new
  success = verifier.verify_economic_fields
  exit(success ? 0 : 1)
end