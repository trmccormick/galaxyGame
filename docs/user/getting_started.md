# Quick Start Guide - Enhanced UI

## Start the Server

```bash
cd /Users/tam0013/Documents/git/galaxyGame/galaxy_game
bundle exec rails server
```

## Open in Browser

Navigate to: **http://localhost:3000/game**

## What You Should See

1. **Top Menu Bar** (dark gray)
   - View, Navigation, Simulation, Help menus
   
2. **Main Canvas** (black with stars)
   - Solar system with sun in center
   - Planets orbiting (if seed data loaded)
   
3. **Right Panel** (dark background)
   - Time controls (Run/Pause, Speed buttons)
   - System information
   - Notifications feed

4. **Bottom Panel** 
   - Speed controls (1x-5x)
   - Time jump buttons (+1 day, +1 week, etc.)

## First Actions to Try

### 1. Check if Data is Loaded
If you see "No celestial bodies found", run seed data:
```bash
bundle exec rails db:seed
```
Then refresh the browser.

### 2. Interact with Planets
- **Hover** over a planet → white glow appears
- **Click** a planet → blue ring appears, details show on right
- **Click tabs** (Atmosphere, Hydrosphere, Geosphere) → see different data

### 3. Control Time
- Click **"Run"** → time starts advancing
- Click **speed buttons** (1x-5x) → change simulation speed
- Click **"+1 Day"** → jump forward instantly
- Watch **event log** → see notifications of actions

### 4. Toggle Views
- Hover over **"View"** menu
- Click **"Toggle Labels"** → planet names disappear/appear
- Click **"Toggle Orbits"** → orbit lines disappear/appear
- Click **"Toggle Moons"** → moons disappear/appear

## Console Check

Open browser DevTools (F12) → Console tab

You should see:
```
Enhanced Game interface loaded
UI Manager initialized
System Renderer initialized
Loaded X celestial bodies
```

No red errors should appear.

## What Each Color Means

### Planets
- **Orange/Red** - Hot terrestrial (Venus)
- **Blue** - Habitable terrestrial (Earth)
- **Gray** - Cold terrestrial (Mars)
- **Yellow/Orange** - Gas giant (Jupiter, Saturn)
- **Light Blue** - Ice giant (Uranus, Neptune)

### Atmosphere Glow
- Blue glow around planet = has significant atmosphere

### Events Log
- **Blue** - Info (general messages)
- **Green** - Success (completed actions)
- **Yellow** - Warning (important notices)
- **Red** - Error (failures)

## Common Issues & Fixes

### Issue: Blank canvas
**Fix**: Run `rails db:seed` to load celestial bodies

### Issue: Menus don't dropdown
**Fix**: Verify you're hovering over menu text, wait 0.5s

### Issue: Can't click planets
**Fix**: Check console for errors, verify all JS files loaded in Network tab

### Issue: No atmosphere data showing
**Fix**: Verify seed data includes atmosphere records for planets

### Issue: Time doesn't advance
**Fix**: Click "Run" button first, check speed is > 1x

## Data Examples

When you click **Earth**, you should see:
- **Type**: terrestrial
- **Mass**: ~1.0 M⊕ (Earth masses)
- **Radius**: ~6371 km
- **Temp**: ~288 K (15°C)
- **Atmosphere**: N₂ 78%, O₂ 21%, Ar 1%, CO₂ 0.04%

When you click **Mars**, you should see:
- **Type**: terrestrial  
- **Mass**: ~0.107 M⊕
- **Radius**: ~3390 km
- **Temp**: ~210 K (-63°C)
- **Atmosphere**: CO₂ 95%, N₂ 3%, Ar 2%

## Testing Terraforming Integration

Currently, terraforming status will show as empty. To add it:

1. Run a terraforming mission (if you have the rake task)
2. Planet data should update with `terraforming_status`
3. Progress bar will appear in detail panel

## Performance Tips

- Runs smoothly at 30 FPS on most hardware
- If laggy, try closing other browser tabs
- Event log auto-limits to 50 entries
- Server polls every 2 seconds (only when running)

## Next Steps

1. ✅ Verify everything displays correctly
2. ✅ Test all interactive features
3. ✅ Check event log tracks actions
4. 🔜 Add real terraforming data
5. 🔜 Create mission tracking panel
6. 🔜 Add resource flow visualization

## Success!

If you can:
- See planets orbiting the sun
- Click a planet and see its details
- Switch between data tabs
- Run/pause time and see it advance
- See events in the notification log

**Your enhanced UI is working perfectly!** 🎉🚀

---

For detailed technical information, see:
- `UI_ENHANCEMENTS_README.md` - Full feature documentation
- `REFACTORING_SUMMARY.md` - What was changed and why

Enjoy your enhanced space simulation UI!
