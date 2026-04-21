# Quick Wins: Restore in Settings, annual pre-select + weekly price, MetricKit, share polish, transformation slide, opt-in analytics

All items below are implemented and the app builds cleanly.

## Paywall polish
- [x] Annual plan pre-selected the moment the paywall opens.
- [x] "≈ $X.XX/week" line shown under the annual price.
- [x] "What changes after 7 days" transformation slide shown before the paywall with three before/after lines.

## Settings
- [x] Restore Purchases row inside the Subscription section (always one tap away).
- [x] Privacy & Insights section with opt-in toggle, off by default.
- [x] Privacy copy updated to describe the opt-in clearly.

## Share card polish
- [x] Pre-filled share caption: "Day {streak} earned. ✨ — Earned app".
- [x] Subtle "MVM EARNED" wordmark in the bottom of exported share cards.

## Stability
- [x] MetricKit crash & hang logger wired in at app launch (no third-party SDK, no extra permissions).

## Dead-code check
- [x] `StreakShieldService` reachable (used in DayCompleteView).
- [x] `PhotoFilterService` reachable (used in ShareCardViewModel).
- [x] `AIAffirmationView` does not exist in the project — nothing to remove.

## What stays exactly as it is
- Today / Swipe flow, Journal, Progress, Reflection Rings, Calendar, onboarding screens, milestones, Game Center, widget, Live Activity, daily nudge, weekly momentum, AI coach, PDF export — untouched.
- No pricing changes. No screen reorganization. No new permissions.
