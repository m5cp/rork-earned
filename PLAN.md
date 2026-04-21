# Add daily reflection caps (1 free / 2 premium), remove lifetime plan, update pricing copy

## Daily reflection limits

- **Free users:** 1 AI reflection per day. When they tap "Write my journal entry" or "Regenerate" a second time, show a friendly "Daily limit reached" screen with an **Upgrade to Premium** button.
- **Premium users:** 2 AI reflections per day. When they try a third, show a friendly "You've used today's reflections" message with a gentle "Come back tomorrow" note and the exact reset time (local midnight).
- Both caps count any successful AI generation (including regenerations).
- Editing and saving your already-generated entry does **not** count — users can always revise and re-save.
- The reflection ring still closes for the day whether they used 0, 1, or 2 reflections — just logging and swiping the cards counts.

## Remove Lifetime plan

- Remove the Lifetime option from the paywall entirely (Monthly and Yearly only).
- Remove Lifetime from the second-chance overlay and sort order.
- No App Store Connect action needed — the plan simply won't appear in the app even if the product still exists in RevenueCat.

## Paywall pricing copy

- Remove the "Save ~58%" savings percentage from the Yearly option (percentages vary by country).
- Replace with neutral, country-safe copy:
  - **Monthly:** "Billed monthly"
  - **Yearly:** "Best value · {price}/week" (RevenueCat auto-localizes the per-week price)
- Keep the "BEST VALUE" badge on Yearly.
- Actual prices ($11.99/month, $59.99/year) are updated by you in App Store Connect — the app reads them live from RevenueCat, so the new prices will appear automatically once approved.

## How this compares to similar apps (2026)

**Verdict:** $59.99/year is right in the pocket for AI-journaling apps — matches Reflectly and Stoic Premium exactly. $11.99/month is slightly above the $9.99 norm but justified by AI generation; it also widens the monthly→yearly gap, which pushes more users into the (higher-LTV) annual plan. Removing Lifetime is the right call for a subscription-first business and is consistent with Reflectly, Finch, and Day One.

## Pages / Screens affected

- **Today → Journal card:** New "Daily limit reached" state with upgrade CTA (free) or "come back tomorrow" copy (premium).
- **Paywall:** Lifetime row removed; savings-percentage text replaced with neutral per-week pricing.
- **Second-chance paywall:** Lifetime removed from sort.
- No other screens change.

