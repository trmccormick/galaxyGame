# Settlement Ownership and Governance

**Status:** ESTABLISHED INTENT with unresolved legal/economic details  
**Last Updated:** 2026-11-11  
**Related:** [Settlement Progression and Footholds](settlement_progression_and_footholds.md), [AI Manager Logic](../logistics/ai_manager_logic.md)

This page records the distinction among a Settlement, a Colony, a corporation, and a player. These are separate entities with relationships to one another; they must not be collapsed into one organizational object.

## 1. Distinct entities

**ESTABLISHED INTENT — 2026-11-11**

- **Settlement:** A physical inhabited and developed place, comparable to a city, municipality, or company town. It has population, housing, facilities, services, industry, infrastructure, and ongoing operational needs.
- **Colony:** A government-like political entity that governs multiple settlements and establishes laws and regulations. A Colony is not simply a populated planet, a settlement, or an industrial site.
- **Corporation:** An ownership and operational entity that may build, own, fund, operate, and maintain settlements and other assets.
- **Player:** A participant who may own assets or organizations and take permitted actions in the game. A player is not interchangeable with a corporation, settlement, or Colony.

## 2. Ownership and governance are separate

A Settlement may be owned by a player or corporation while also belonging to and being governed by a Colony. The Colony that governs a Settlement does not therefore automatically own the Settlement or all of its assets.

A useful analogy is a corporation-owned company mining town. The corporation may build and own housing, utilities, industrial facilities, and other infrastructure because it needs a workforce and an operating location. The place is still subject to the laws and regulations of the Colony whose jurisdiction it has joined. Corporate ownership does not grant an exemption from Colony governance.

A corporation may own multiple Settlements that are governed by different Colonies.

## 3. Separate responsibility relationships

The game model and its interfaces must keep these questions distinct:

| Relationship | Question |
|---|---|
| Ownership | Who owns the Settlement and its assets? |
| Governance | Which Colony governs it, and which laws and regulations apply? |
| Operations | Who manages day-to-day activity? |
| Maintenance | Who is responsible for maintaining infrastructure and systems? |
| Funding | Who pays for services, maintenance, and shared infrastructure? |

These responsibilities may be held by different entities and should be visible as separate relationships where relevant. Do not assume that the owner, governor, operator, maintainer, and funder are always the same organization.

## 4. Mutual support

**ESTABLISHED INTENT — 2026-11-11**

The relationship between a Colony and its Settlements is not only regulatory. Support can flow in both directions.

A Colony may support a Settlement through shared services, public infrastructure, coordination, emergency assistance, subsidies, or other forms of help. A Settlement may contribute to its Colony through taxes or revenue, resources, industrial output, labor, expertise, and services.

The exact funding formulas, service obligations, and economic transfers remain open and must not be invented by interface design.

## 5. Corporate withdrawal and transfer of control

**ESTABLISHED INTENT — 2026-11-11**

If a corporation decides to leave a Settlement it controls, control of that Settlement must be turned over to the Colony governing it. The corporation cannot simply abandon the Settlement and leave its population and continuing civic responsibilities without a governing authority.

**OPEN — transfer mechanics:** The precise treatment of legal ownership, buildings and other assets, outstanding debts, contracts, inventories, maintenance backlogs, ongoing operations, and compensation has not yet been decided. Do not infer that every asset automatically transfers or invent a settlement liquidation process. The established intent is the transfer of control to the Colony; the detailed legal and economic mechanics require separate decisions.

## 6. Implications for the UI and AI Manager

- Show Settlements, Colonies, corporations, and players as distinct entity types.
- Make ownership and governance independently discoverable; do not model a Settlement as merely a child object owned by its Colony.
- Allow navigation from a Settlement to its owner, governing Colony, operator, maintenance responsibility, and funding relationships where those are known.
- Allow a Colony view to show the multiple Settlements it governs, without implying it owns them all.
- Allow a corporation view to show its portfolio of Settlements, including Settlements under different Colony governments.
- The AI Manager should be able to identify who is responsible for an issue and which organization can provide support or take action.
- Corporate withdrawal should be represented as a control-transfer event to the governing Colony. The unresolved asset and liability details must remain explicit.

This page records domain intent, not a final database schema or UI layout.

## Change history

- **2026-11-11** — Recorded the distinct entity model, separation of ownership/governance/operations/maintenance/funding, mutual support, and corporate-withdrawal control-transfer rule.
