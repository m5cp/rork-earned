# Merge onboarding into one, clean up Settings, remove Game Center & Leaderboard

## What I'll change

**One onboarding, shown once**
- Remove the separate Welcome intro screen so there's only a single onboarding flow the first time someone opens the app.
- Keep the existing 5-page onboarding (Own your wins → Build momentum → AI journal → Track mood → Say it out loud) as the sole first-run experience.
- After it's completed once, it will never show again (this is already stored on the device — I'll make sure the old welcome flag doesn't re-trigger it).

**Remove Game Center entirely**
- Delete the Game Center sign-in, authentication, and score submission throughout the app.
- Remove the Game Center section from Settings.
- Remove the Game Center auto-authenticate on app launch.

**Remove the Leaderboard**
- Delete the Leaderboard preview card from the Progress tab.
- Remove all leaderboard code and references.

**Fix the Settings page layout**
- Align every section header and row consistently to the left edge of the cards.
- Fix the indented/misaligned rows under Daily Nudge (time picker and frequency picker were pushed too far right).
- Consolidate the duplicated "Privacy" and "Privacy & Insights" sections into a single clean Privacy section.
- Make sure icon sizes, row padding, and spacing match across every group so the whole screen reads as one tidy list like native iOS Settings.
- Keep all existing functionality: reminders, calendar sync, appearance, privacy insights toggle, support, legal, data reset, export, about.

## Result
- First launch: one clean onboarding, then straight into the app.
- Returning users: never see onboarding again.
- No Game Center, no leaderboard anywhere in the app.
- Settings page looks polished, consistent, and properly left-aligned.
