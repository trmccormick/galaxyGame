# 📈 Financial Engine & Market Taxes

## 1. Component/System Mapping
- **Source Reference:** Extracted from root README economic specifications and game-dev balancing structures.
- **Core System Code:** `MarketService`, `Finance::TransactionLedger`, `AccountBalancesController`
- **Related Documentation:** `docs/architecture/financial_system.md`

## 2. Currency Structures & Exchange Rules

### The GCC-USD Bootstrap Peg
- **Initial Bootstrapping:** To establish a stable foundation for the initial lunar and orbital market ecosystems, the Global Colonization Credit (GCC) is strictly pegged 1:1 with United States Dollars (1 GCC = 1 USD).
- **Macroeconomic Uncoupling:** Earth-bound operations do not naturally utilize the GCC framework. Corporations operating out of Earth terrestrial zones are paid in USD, which they subsequently use to buy Earth-based imports. 
- **Dynamic Float Trigger:** At a predetermined simulation scale threshold—where space-based extraction, local manufacturing, and interplanetary circulation become self-sustaining—the engine will trigger an uncoupling event, allowing the GCC to float dynamically against the USD based on real supply/demand metrics.

## 3. PLEX Market Transaction Tax Architecture
When players or AI agents interact with regional market hubs to place buy or sell limit orders (specifically for high-value transactional items like PLEX), the backend applies a strict multi-tiered fee structure. These friction rates must be accounted for by order-placement engines to prevent bankrupting multi-order trading strategies (such as deploying 1,000 order clusters).

### Fee and Tax Schedule

| Tax / Fee Type | Percentage Rate | Engine Execution Layer |
| :--- | :--- | :--- |
| **SCC Surcharge** | 0.50% (`0.005`) | Deducted instantly upon order matching and execution. |
| **Broker Fee** | 0.30% (`0.003`) | Deducted immediately from player liquidity upon placing the limit order. |
| **Sales Tax** | 3.37% (`0.0337`) | Applied directly to the gross revenue of the seller upon transaction finalization. |

### Profitability Validation Logic
To determine if placing a buy/sell spread for a high-volume block of orders is profitable after tracking all systemic transaction friction, the engine evaluates the spread using the following formula:

$$\text{Net Profit} = \left[ \text{Sell Price} \times (1 - \text{Sales Tax} - \text{SCC Surcharge}) \right] - \left[ \text{Buy Price} \times (1 + \text{Broker Fee}) \right]$$

In code implementation constraints:
```ruby
net_profit = (sell_price * (1 - 0.0337 - 0.005)) - (buy_price * (1 + 0.003))
return true if net_profit > 0
