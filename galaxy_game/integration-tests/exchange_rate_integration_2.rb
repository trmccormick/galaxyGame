# Exchange Rate Integration Test: Bond Repayment Under Fluctuation
# This test validates the core ExchangeRateService by simulating the risk
# of a USD-denominated debt (a bond) being repaid using depreciated GCC revenue.

require 'date'
require 'securerandom'
require_relative '../app/services/financial/exchange_rate_service' # Now requiring the real class
require_relative '../app/models/organizations/base_organization'
require_relative '../app/models/financial/account'
require_relative '../app/models/financial/currency'
require_relative '../app/models/financial/bond' # Assuming Bond model exists

puts "\n💵 Starting Exchange Rate Bond Risk Test (Instance-Based Validation)..."

# === Test Constants ===
BOND_AMOUNT_USD = 1857986.22 
SIMULATION_DAYS = 180
DAILY_GCC_REVENUE = 864.0 

# === 1. Setup Context & Entities ===
ldc = Organizations::BaseOrganization.find_by!(identifier: "LDC")
astrolift = Organizations::BaseOrganization.find_by!(identifier: "ASTROLIFT")

# --- Currencies ---
gcc_currency = Financial::Currency.find_by!(symbol: 'GCC')
usd_currency = Financial::Currency.find_by!(symbol: 'USD')
puts "✅ Organizations and Currencies initialized."

# --- Accounts ---
ldc_gcc_account = Financial::Account.find_or_create_for_entity_and_currency(accountable_entity: ldc, currency: gcc_currency)
astrolift_gcc_account = Financial::Account.find_or_create_for_entity_and_currency(accountable_entity: astrolift, currency: gcc_currency)

# Reset LDC account for the test 
ldc_gcc_account.update!(balance: 0.0)

puts "💰 Initial Balances Established:"
puts "  - LDC GCC: #{ldc_gcc_account.balance.to_f.round(2)} GCC"
puts "  - Bond Amount: $#{BOND_AMOUNT_USD.round(2)} USD"

# === 2. Exchange Rate Configuration: INITIAL PEG (1:1) ===
# We must now create an instance of the service
rate_service = Financial::ExchangeRateService.new
rate_service.set_rate('USD', 'GCC', 1.0)
rate_service.set_rate('GCC', 'USD', 1.0) # Set inverse rate for completeness

puts "\n📈 Initial Rates (1:1 Peg):"
puts "  - 1 USD = #{rate_service.get_rate('USD', 'GCC').round(4)} GCC"
initial_gcc_cost = rate_service.convert(BOND_AMOUNT_USD, 'USD', 'GCC')
puts "  - Required GCC for Bond Repayment: #{initial_gcc_cost.round(2)} GCC"
puts "  ✅ LDC would need #{initial_gcc_cost.round(2)} GCC to repay the debt today."

# === 3. Bond Creation (Simulating Launch Debt) ===
issued_at = Date.today
due_at = issued_at + SIMULATION_DAYS
bond = Financial::Bond.create!(
  issuer: ldc,
  holder: astrolift,
  currency: usd_currency,
  amount: BOND_AMOUNT_USD,
  issued_at: issued_at,
  due_at: due_at,
  status: :issued,
  description: "Test Bond for Launch Cost"
)
puts "\n🪙 Bond created: ID #{bond.id} for $#{BOND_AMOUNT_USD} USD, Due: #{due_at.strftime('%Y-%m-%d')}"

# === 4. Simulation Loop (Revenue Generation) ===
puts "\n🔄 Simulating #{SIMULATION_DAYS} days of revenue generation..."
total_simulated_revenue = SIMULATION_DAYS * DAILY_GCC_REVENUE
ldc_gcc_account.deposit(total_simulated_revenue, "Simulated revenue over #{SIMULATION_DAYS} days")
puts "  - Total GCC Deposited: #{total_simulated_revenue.round(2)} GCC"
puts "  - LDC GCC Final Balance: #{ldc_gcc_account.reload.balance.to_f.round(2)} GCC"

# === 5. CRITICAL TEST: Currency Fluctuation ===
# Simulate GCC depreciating against the USD: 1 USD now buys 1.3 GCC
puts "\n📉 CRITICAL TEST: Simulating GCC Depreciation..."
rate_service.set_rate('USD', 'GCC', 1.30)
rate_service.set_rate('GCC', 'USD', 1.0 / 1.3) # 1 GCC = 0.7692 USD

final_usd_rate_to_gcc = rate_service.get_rate('USD', 'GCC')
final_gcc_rate_to_usd = rate_service.get_rate('GCC', 'USD')


puts "  - New USD to GCC rate: 1 USD = #{final_usd_rate_to_gcc.round(4)} GCC"
puts "  - New GCC to USD rate: 1 GCC = $#{final_gcc_rate_to_usd.round(4)} USD"
puts "  - GCC has depreciated by #{(1.0 - final_gcc_rate_to_usd) * 100.0}%"


# === 6. Bond Maturity and Repayment under New Rate ===
puts "\n13. Bond Maturity and Repayment..."
bond_amount = bond.amount 

# Convert the USD debt amount to the required GCC repayment amount at the new, depreciated rate
required_gcc_repayment = rate_service.convert(bond_amount, 'USD', 'GCC')
available_gcc = ldc_gcc_account.balance.to_f

puts "    Repayment Check for Bond ##{bond.id} (USD Debt: $#{bond_amount.round(2)} USD)"
puts "    Required GCC Repayment at today's rate: #{required_gcc_repayment.round(2)} GCC"

if available_gcc >= required_gcc_repayment
  ldc_gcc_account.transfer_funds(required_gcc_repayment, astrolift_gcc_account, "Bond repayment in GCC for Bond ##{bond.id}")
  bond.update!(status: :paid)
  puts "💸 Bond ##{bond.id} repaid successfully."
  puts "    Repayment Cost: **#{required_gcc_repayment.round(2)} GCC**"
  puts "    Initial Expected Cost (1:1): 1857986.22 GCC"
  puts "    **Increased Cost:** #{(required_gcc_repayment - 1857986.22).round(2)} GCC (30.0% increase due to depreciation)"
else
  puts "⚠️ Not enough GCC to repay Bond ##{bond.id}. Outstanding: #{required_gcc_repayment.round(2)} GCC, Available: #{available_gcc.round(2)} GCC"
end

# === 7. Final Verification and Cleanup ===
# Note: Cleaning up the Bond record to allow re-runs of the test
bond.destroy

puts "\n✅ Final Status:"
puts "  - LDC GCC Balance: #{ldc_gcc_account.reload.balance.to_f.round(2)} GCC"
puts "  - AstroLift GCC Balance: #{astrolift_gcc_account.reload.balance.to_f.round(2)} GCC"

puts "\n🏁 Exchange Rate Bond Risk Test Complete."