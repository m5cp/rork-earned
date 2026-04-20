# Add Apple Fitness-style Reflection Rings to Progress tab

## Reflection Rings

Three concentric rings at the top of the Progress tab — inspired by Apple Fitness — that fill as you complete your daily reflection practice.

### The three rings

- **Check-In** (outer, warm red/orange) — closes when you complete today's check-in
- **Reflect** (middle, green) — closes when you journal or do "Say It Out Loud"
- **Mood** (inner, blue/cyan) — closes when you log today's mood

All three closed = a perfect reflection day. A subtle celebration plays the first time you close all three in a day.

### Progress tab — hero section

- The three stat cards currently at the top are replaced by a large, animated Reflection Rings hero card
- Rings animate filling in when the tab appears
- Three small legend pills below the rings show today's status for each ring with a percentage
- A tiny "Today" label and date sit above the rings
- Tapping the hero opens today's Ring Detail sheet

### Monthly ring calendar

- Below the hero, a new "Rings" section shows a month grid
- Each day is a tiny three-ring icon (same Apple Fitness style) showing how close each ring was to being closed that day
- Future days are dimmed; today is highlighted with a subtle outline
- Arrows at the top let you move between months; you can't go past the current month
- Tapping any past or current day opens the Ring Detail sheet for that day
- The existing activity calendar below remains unchanged

### Ring Detail sheet

- Opens when you tap the hero or any day in the ring calendar
- Shows the selected date with large three-ring view at the top
- Three expanded rows below — one per ring — each showing ring color, name, status (e.g. "Checked in", "Not logged"), and percentage
- A small summary line: "2 of 3 rings closed" or "Perfect day — all rings closed"
- If viewing today and a ring isn't closed, a gentle CTA button appears ("Log mood", "Start check-in", etc.) that jumps to that flow
- For past days, the view is read-only

### Design

- Rings use thick rounded stroke with a soft gradient, glowing slightly when fully closed
- Apple Fitness-style spacing: rings nest with ~6pt gaps between them
- Smooth spring-based fill animation when the view appears or values change
- Soft haptic tap when a ring closes in real time
- Works in both light and dark mode with semantic colors
- Reduced Motion: rings appear already filled without animation

### Where things live

- **Progress tab top:** Reflection Rings hero (replaces the three stat cards)
- **Progress tab middle:** new monthly ring calendar section
- **Progress tab rest:** AI Coach, Mood, Weekly Momentum, Weekly Insight link, Activity calendar, 7-day chart — all stay as they are
- **Ring Detail sheet:** new sheet reachable from hero or any day in the ring calendar

