Session Handoff — 2026-04-16
Session Metrics
Start: 1885 examples, 1 failure, 29 pending (models suite)
End: 1885 examples, 1 failure, 29 pending (no change — all additions)
Commits: a4ae9dd4, db350ace, 274cb808
Tasks completed: 3
Tasks created: 5
Time: full session
Agent: GPT-4.1 (implementation), Claude (strategist/planner)
Branch: regional-view-phase2
Current Baseline
1885 examples, 1 failure, 29 pending (models suite)
1 pre-existing failure: spec/models/item_spec.rb:296 — unchanged, not this session's responsibility
Commits This Session
HashDescriptiona4ae9dd4fix: adapted_features — polymorphic settlement associationdb350acerefactor: system_builder_service — major moon hardcoded names replaced274cb808test: extraction_service_spec — missing spec coverage added
Tasks Completed This Session

2026-04-12-LOW-BUG-FIX-GEOLOGICAL-FEATURES-SETTLEMENT-POLYMORPHIC.md → completed
2026-04-14-MEDIUM-REFACTOR-SYSTEM-BUILDER-MAJOR-MOON-HARDCODED-NAMES.md → completed
2026-04-14-MEDIUM-BUG-FIX-EXTRACTION-SERVICE-SPEC-MISSING.md → completed

Superseded Tasks — Move to Completed
Both superseded by the five new docking/market tasks:

2026-04-12-HIGH-ARCHITECTURE-GAS-STORAGE-CONCERN-DESIGN.md
2026-04-12-HIGH-ARCHITECTURE-UNIFIED-DOCKING-EXCHANGE-MARKET-SYSTEM.md

Add note in each: "Superseded by 2026-04-16 docking transaction system scope."
Architecture Decisions Made This Session
DecisionDetailadapted_features polymorphic settlementbelongs_to :settlement moved to BaseFeature, polymorphic, removes hardcoded BaseSettlement from subclassesMajor moon classificationReplaced hardcoded name list with properties.major_moon flag + mass > 1e20 threshold fallback in system_builder_service.rbsol.json / sol-complete.json syncJSON data gitignored, backed up via Time Machine. Both files updated with major_moon: true flags — not committedDocking always freeNo landing or docking fees. Fees on transactions onlyFee modelBroker fee on placement + transaction fee on fill. Both owner-configurable, system default fallback. Same-owner waives bothOrder book locationMarketplace stays on settlement. Structures get their own marketplace. Craft transacts against docking point's marketplace onlyPhysical inventory boundaryCraft can only transfer to/from the structure it is physically docked at — not settlement-wideFinancial counterpartystructure.owner not settlement — ownership is separate from locationSurface outdoor storagestate_at_stp == solid + stability == stable + non-hazardous transport category → outdoor eligible, unlimited capacityEVE order modelLimit orders + market orders, durations 1/3/7/30/90 days, partial fills supportedRaw resource floor priceBreak-even cost model: fuel + depreciation + energy + risk ÷ kg extracted. Feeds into NpcPriceCalculator as floor
New Backlog Tasks Created
FilePriorityAgentBlocked By2026-04-16-MEDIUM-DATA-ECONOMIC-PARAMETERS-MARKET-FEES.mdMEDIUMGPT-4.1Nothing2026-04-16-HIGH-FEATURE-MARKETPLACE-ON-STRUCTURE.mdHIGHGPT-4.1Nothing2026-04-16-MEDIUM-ARCHITECTURE-MATERIAL-STORAGE-CLASSIFICATION.mdMEDIUMDesign sessionNothing2026-04-16-HIGH-ARCHITECTURE-RAW-RESOURCE-EXTRACTION-PRICING.mdHIGHDesign sessionNothing2026-04-16-HIGH-FEATURE-DOCKING-TRANSACTION-SERVICE.mdHIGHGPT-4.1Tasks 1 + 2
Next Session Priorities
#TaskAgentNotes1Economic parameters feesGPT-4.1Simple data edit, no blockers, warm-up task2Marketplace on structureGPT-4.1Migration + model change, no blockers3Material storage classificationDesignReview derivation logic vs explicit flag decision4Raw resource extraction pricingDesignBreak-even model design, feeds NpcPriceCalculator5Docking transaction serviceGPT-4.1Blocked until 1 + 2 complete
Notes for Next Session

GPT-4.1 supervision note carries forward: watch carefully on any task involving data file edits, numeric constants, JSON serialization, or Docker commands. Always verify commands target Docker paths not host paths before approving.
The two superseded architecture tasks should be moved to completed before next session starts to keep backlog clean.
sol.json and sol-complete.json major moon flags are live in Docker volume but not committed — gitignored by design, Time Machine backup on host.
OrbitalSettlement reaches celestial body through structures.first&.celestial_location&.celestial_body — no direct belongs_to :celestial_body. Keep this in mind for any future task touching orbital settlement location.
ExcavatedCavity → OrbitalSettlement conversion pipeline (asteroid excavation → unit installation → station) is still undesigned. Backlog task needed before any implementation. Not written this session — add to backlog when docking system is complete.
Slag as propellant mechanic (excavation byproduct used for asteroid repositioning) is also undesigned. Depends on conversion pipeline design above.