
AI_MANAGER_COMMAND.md — Final Authority

## MANDATORY DELEGATION (Existing Services)

✅ Market::NpcPriceCalculator.calculate_spread() → Strategic pricing
✅ Tier1PriceModeler.calculate_eap() → Bootstrap pricing
✅ Market::PriceHistory.where(...) → Market maturity check
✅ orbital_depot_mk1_bp.json → L1 fuel monitoring target

**MANDATORY PATTERNS** (Violations = immediate rejection):

1. **Manifest Generation** (Primary output)
manifest = {
source_dc: 'EARTH',
target_dc: 'LUNAR_BASE_01',
cargo: { 'modular_structural_panel': 150, 'cryogenic_tank_module': 12 },
economics: { gcc_cost: 50000, usd_cost: 25000, roi_years: 1.8 },
priority: 'terraforming_enabler'
}

text

2. **Economics Driver** (All decisions)
gcc_price = CurrencyRate.latest_rate('GCC_USD')
transport_cost = LaunchPaymentService.estimate_cost(cargo_mass, source_dc, target_dc)
net_roi = projected_revenue - transport_cost
→ Decision matrix: if net_roi > threshold

text

3. **GCC Ledger Trading** (Decision options)
trading_options = [
{ action: 'sell_gcc_for_usd', amount: 25000, source: 'LDC_gcc_account' },
{ action: 'issue_bond_gcc', maturity_days: 180, terms: 'terraforming_funding' },
{ action: 'trade_gcc_for_materials', partner: 'ASTROLIFT', ratio: 1.2 }
]
→ Select optimal: minimize usd_outlay, maximize dc_expansion_velocity

text

4. **DC-Tied Expansion** (Terraforming/Base decisions)
dc_expansion = {
dc_id: 'LUNAR_BASE_01',
phase: 'terraforming_phase2',
dependencies: ['isru_online', 'power_surplus_10mw'],
manifest_required: ['water_extractor', 'co2_reactor', 'algae_bioreactor']
}

text
Decision Matrix (AI Manager MUST implement)
text
Economics Input → Trading Decision → Manifest Output → Execution

GCC Ledger Balance    | USD Liquidity | Trading Action       | Manifest Priority
---------------------|---------------|---------------------|------------------
> 100k GCC           | High          | Direct build        | Terraforming
> 100k GCC           | Low           | Issue bonds         | Base expansion  
< 100k GCC           | High          | Buy GCC market      | Maintenance
< 100k GCC           | Low           | GCC/USDT swap       | Critical only
Training Data Compliance (88→8 refactor target)
text
**Phase 1**: GCC bootstrap (working) → data/json-data/missions/gcc_sat_mining_deployment/
**Phase 2**: Manifest generation → AI Manager generates own JSON manifests
**Phase 3**: DC expansion → Terraforming/base decisions tied to economics
**Phase 4**: Trading engine → GCC ledger options evaluation
Immediate Audit Commands
bash
# Economics delegation check
grep -r "LaunchPaymentService\|CurrencyRate\|Account" app/services/ai_manager/

# Manifest generation check  
grep -r "manifest\|cargo:\|economics:" app/services/ai_manager/

# Trading logic check
grep -r "GCC\|trading\|bond\|ledger" app/services/ai_manager/ | grep -v "comment"
Status: Command spec locked. Manifest generation + GCC trading + DC economics = canonical AI Manager. Hardcoded bloat identified for surgical removal.
