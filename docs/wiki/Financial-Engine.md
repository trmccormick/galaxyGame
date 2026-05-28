# 📈 Financial Engine & Market Systems

## 1. Component/System Mapping
- **Source Reference:** Extracted from core economic design specifications and game-dev balancing structures.
- **Core System Code:** `MarketService`, `Finance::TransactionLedger`, `AccountBalancesController`
- **Related Documentation:** `docs/architecture/financial_system.md`

## 2. Currency Structures & Exchange Rules

### The GCC-USD Bootstrap Peg
- **Initial Bootstrapping:** To establish a stable foundation for the initial lunar and orbital market ecosystems, the Global Colonization Credit (GCC) is initially pegged 1:1 with United States Dollars (1 GCC = 1 USD).
- **Macroeconomic Mechanics:** Earth does not naturally utilize the GCC framework. Corporations operating out of Earth terrestrial zones are paid in USD. They use these USD balances to purchase Earth-based imports for the colonies.
- **Dynamic Float Trigger:** Initially, the market engine treats GCC and USD as coupled variables to bootstrap early development. At a predetermined simulation scale threshold—where the space-based market economy becomes large and self-sustaining—the engine will execute an uncoupling event, allowing the GCC to unpeg from the USD and float dynamically based on real orbital supply and demand metrics.

## 3. Market Transaction & Order Validation
When players or the AI Manager deploy large blocks of trade orders (such as simulating a 1,000 order milestone cluster), the system processes them through local market hubs. 

To prevent bad automated trading logic from bleeding corporate capital, any order placement loop must validate basic transactional profitability against localized costs before issuing batch commands.

### Order Profitability Verification Structure
```ruby
# Basic financial gate for high-volume automated ordering loops
def valid_margin?(buy_price, sell_price, transaction_fees)
  net_profit = sell_price - buy_price - transaction_fees
  net_profit > 0
end