# Quick Wins: Restore in Settings, annual pre-select + weekly price, MetricKit, share polish, transformation slide, opt-in analytics

Here's what I'll change — nothing working today gets touched.

## Paywall polish
- Annual plan is pre-selected the moment the paywall opens (instead of no selection).
- Under the annual price, add a small "≈ $X.XX/week" line so the value feels concrete.
- Add a new **"What changes after 7 days"** transformation slide that appears right before the paywall — a clean visual with three short before/after lines (e.g. "Forgetting wins → Noticing them daily", "Guilty rest days → Proud rest days", "No rhythm → A streak you care about"). Honest, aspirational, no false claims.

## Settings
- Add a **Restore Purchases** row inside the Subscription section so it's always one tap away (Apple prefers this).
- Add a **Privacy & Insights** section with a single opt-in toggle: "Help improve Earned — share anonymous usage." Off by default. When on, the app sends anonymous, non-personal events (screens viewed, paywall shown/purchased, check-in completed) to a privacy-first analytics service. No names, no content, no device IDs beyond an anonymous install token. When off, nothing is sent.
- Update the existing privacy copy from "No analytics or ad networks" to clearly describe the opt-in ("Anonymous usage insights are off by default. You can enable them in Settings.").

## Share card polish
- When the user taps Share on a card, a pre-filled caption comes along: "Day {streak} earned. ✨ — Earned app"
- Add a subtle "Earned" wordmark in the bottom corner of exported share cards so it travels with the image.

## Stability
- Wire in a lightweight crash & hang logger (Apple's built-in MetricKit — no third-party SDK, no extra permissions). Reports are collected silently and saved locally so you can see them after TestFlight runs.

## Dead-code check
- Verify `StreakShieldService`, `PhotoFilterService`, and `AIAffirmationView` are actually reachable. If any are orphaned, I'll either wire them to an existing surface or remove them (removing reduces App Review risk).

## What stays exactly as it is
- Today / Swipe flow, Journal, Progress, Reflection Rings, Calendar, onboarding screens, milestones, Game Center, widget, Live Activity, daily nudge, weekly momentum, AI coach, PDF export — untouched.
- No pricing changes. No screen reorganization. No new permissions.

After I make the changes I'll build the app to confirm everything still compiles, and you'll see the updates live in the preview.