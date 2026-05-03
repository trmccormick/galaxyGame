# Galaxy Game Time & Speed Mechanics Discussion
**Date:** February 14, 2026
**Context:** Post-FreeMars analysis - addressing real-time vs turn-based differences
**Focus:** Time acceleration, game pacing, and balance considerations

## 🎯 Core Difference: Real-Time vs Turn-Based

### FreeMars (Turn-Based)
- **Discrete turns**: Player makes decisions, then time advances
- **Predictable pacing**: Clear action → consequence cycles
- **Strategic depth**: Time for careful planning each turn
- **UI simplicity**: Static displays, no real-time updates needed

### Galaxy Game (Real-Time with Acceleration)
- **Continuous time**: Events happen simultaneously, player intervenes
- **Dynamic pacing**: Multiple things happening at once
- **Reactive strategy**: Respond to changing situations
- **UI complexity**: Live updates, notifications, time controls

**Key Implication**: Galaxy Game needs sophisticated time management and player attention management that FreeMars avoids entirely.

## ⏱️ Time Acceleration & Scaling Discussion

### Current Time Controls
- **Speed settings**: 1x, 5x, 10x, 50x, 100x (from UI screenshots)
- **Time jumping**: +1 day, +1 week, +1 month buttons
- **Pause functionality**: Stop time entirely

### Critical Question: What Does "1 Day" Represent?

**Option 1: Realistic Scale (Too Slow)**
- 1 game day = 1 real day
- Settlement construction: weeks/months
- Wormhole events: years to develop
- **Problem**: Players see minimal progress, lose engagement

**Option 2: Accelerated Scale (Current Assumption)**
- 1 game day = hours of real time?
- Construction: days instead of months
- Events: months instead of years
- **Question**: What's the sweet spot?

**Option 3: Variable Scale (Recommended)**
- Different time scales for different systems
- Sol system: faster (already developed)
- New systems: slower (realistic colonization)
- **Benefit**: Balances realism with engagement

### Proposed Time Scale Framework

**Base Assumption**: 1 game day = 1 real week
- **Construction**: Major projects take days, not months
- **Travel**: Interplanetary trips take hours/days, not months
- **Economic cycles**: Markets fluctuate daily, not yearly
- **Wormhole events**: Buildup takes months, not decades

**Speed Settings Purpose**:
- **1x**: "Real-time" observation mode
- **5x-10x**: Normal gameplay speed
- **50x-100x**: Fast-forward through boring periods
- **Pause**: Strategic planning mode

## 🎮 Player Experience Implications

### Attention Management
**Challenge**: Real-time games require constant attention, but Galaxy Game has long build times
**Solutions**:
- Smart notifications for important events
- Auto-pause on critical decisions
- Background progress tracking
- Summary reports for time-jumped periods

### Decision-Making Cadence
**FreeMars**: Decisions every turn (minutes of real time)
**Galaxy Game**: Decisions every hours/days (game time)
**Need**: Balance between strategic depth and player availability

### Contract System Timing
**FreeMars**: Contracts appear each turn
**Galaxy Game**: Contract timing needs careful balance
- Too frequent: Overwhelming
- Too infrequent: Player disengagement
- **Proposal**: Contracts appear every 4-6 game hours, expire in 24-48 game hours

## 🔧 Technical Implementation Considerations

### Time Acceleration Architecture
**Current**: Simple multiplier on Rails time
**Needed**: More sophisticated system
- **Event scheduling**: Background jobs respect time acceleration
- **AI timing**: Decision frequency scales with game speed
- **Database timestamps**: Store both real time and game time

### Real-Time Updates
**Challenge**: How to show live progress without overwhelming UI
**Solutions**:
- Progressive loading indicators
- Event-driven notifications
- Summary dashboards
- Configurable update frequencies

## 🧪 Testing & Balancing Framework

### Playtesting Protocol
1. **Speed Calibration Testing**
   - Try different time scales (1 day = 1 hour, 1 day, 1 week)
   - Measure engagement vs frustration
   - Track completion times for key milestones

2. **Attention Span Testing**
   - Monitor how long players stay engaged
   - Identify boring periods that need fast-forward
   - Test notification effectiveness

3. **Balance Iteration**
   - A/B test contract frequencies
   - Adjust construction times based on feedback
   - Tune AI decision timing

### Success Metrics
- **Engagement**: Average session length
- **Completion**: Percentage of players reaching wormhole events
- **Satisfaction**: Player feedback on pacing
- **Retention**: Return player rates

## 📊 Specific Time Scale Recommendations

### Construction Times (Game Days)
- **Basic settlement**: 3-5 days
- **Orbital station**: 7-10 days
- **Wormhole infrastructure**: 14-21 days
- **Major terraforming**: 30-60 days

### Travel Times (Game Hours)
- **Earth-Moon**: 2-4 hours
- **Earth-Mars**: 8-12 hours
- **Inter-system (wormhole)**: 1-2 hours

### Event Timings
- **Contract appearance**: Every 6 game hours
- **Contract expiration**: 48 game hours
- **AI decisions**: Every 2-4 game hours
- **Market updates**: Every 12 game hours

### Wormhole Event Timeline
- **Discovery**: Immediate
- **Infrastructure buildup**: 30-60 days
- **Snap risk**: 60-90 days
- **Actual snap**: 90-120 days

## 🤔 Additional Discussion Points

### 1. Player Agency vs Automation
**Question**: How much control vs AI handling?
- FreeMars: Player controls everything
- Galaxy Game: AI handles much, player directs strategy
- **Balance needed**: Player feels in control but isn't overwhelmed

### 2. Multi-System Management
**Challenge**: Managing multiple systems simultaneously
**Solutions**:
- System overview dashboards
- Automated alerts for issues
- Delegation to AI managers
- Focus modes for specific systems

### 3. Economic Pacing
**Question**: How fast should GCC economy move?
- Too fast: Chaotic, hard to track
- Too slow: Boring, no urgency
- **Proposal**: Daily economic cycles with weekly major events

### 4. Tutorial & Onboarding
**Challenge**: Complex time mechanics need explanation
**Need**: Progressive disclosure of time controls
- Start simple (pause/play)
- Introduce acceleration gradually
- Explain time scale assumptions

### 5. Mobile/Web Considerations
**Question**: How does time work for non-real-time players?
- Background progress?
- Email notifications?
- Session-based advancement?

## 🎯 Next Steps

1. **Prototype Time Scales**: Implement basic time acceleration
2. **Playtest Sessions**: Try different scales with test scenarios
3. **Feedback Collection**: Survey players on pacing preferences
4. **Iterate**: Adjust based on engagement metrics
5. **Document**: Create time mechanics guide for players

**Key Decision**: Establish baseline time scale assumption (1 game day = X real time) to guide all balance decisions.