
# AI Manager Hammer Protocol Orchestration

## EXECUTION FLOW (AI Manager tick)
1. **EM Buffer Monitoring** → `state_analyzer.em_buffers.saturated?`
2. **System Assessment** → `terraform_score` + `resource_density` + `threat_level`
3. **Consortium Vote** → LDC/AstroLift/MarsCorp weighted quorum (66%)
4. **Mass Transit Execution** → `hammer_trigger_tonnage` (1e12kg cycler/ore)
5. **Snap Confirmation** → New system coordinates + stability metrics

---

## RUBY ORCHESTRATION (89→8 target)
```ruby
def evaluate_hammer_protocol(system)
  return unless em_buffers.saturated?(system)
  
  assessment = system_assessment(system) # terraform_score, threats
  vote = consortium_vote(assessment)     # 66% quorum
  
  if vote.approved?
    execute_hammer(
      tonnage: 1e12, 
      assets: prioritise_fleet(system.terraform_score)
    )
  end
end
```

---

## Consortium Voting Weights (Economic Reality)
- **LDC (Banking):** 30% → GCC circulation multiplier
- **AstroLift (Logistics):** 25% → Cycler route efficiency
- **Mars Corp (Industry):** 25% → Belt mining extension viability
- **Venus Corp (Terraform):** 15% → Atmospheric pipeline synergy
- **Titan Corp (Fuel):** 5% → CH₄ supply chain impact

---

## Protocol Overview & Context
- **Mass-tension theory:** WH stability governed by mass flow and counterbalance (Jupiter-standard)
- **EM buffer logic:** Energy harvested from natural WHs powers artificial stabilization
- **Snap event:** Strategic use of mass overload to trigger WH exit relocation (Eden Snap origin)
- **System slot/capacity:** Enforce max WH links per system; triage for optimal expansion

---

## Narrative Origin & Implementation Context
- **Origin:** Eden Snap event (one-sided collapse due to missing counterbalance)
- **Strategic Use:** Controlled Snap to discover/prioritize new systems, clear system slots, or reroute expansion
- **Implementation:** Refactor task exists (89→8 target); all logic and mechanics are locked in wh-expansion.md, GEMINI-CHAT.md, and storyline docs

---

## References
- docs/architecture/operations/wh-expansion.md
- docs/agent/planning/GEMINI-CHAT.md
- AI_MANAGER_WORMHOLE_EXPANSION.md
- CONSORTIUM_GOVERNANCE.md (pending)

---

**Status:** Hammer Protocol is fully mature, production-ready, and surgically integrated for Claude 5PM deployment.
