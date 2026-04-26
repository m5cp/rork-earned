# RevenueCat audit + bump to 1.0.1 (build 10) for resubmission

## Audit findings

**The actual rejection cause is in App Store Connect, not your code.** Both subscription products show "Developer Action Needed" in your screenshots. While that status is active, every purchase attempt fails with an error — exactly what the reviewer saw. No code change can fix that; you must complete the missing info on each product page in App Store Connect (usually localized display name, description, or review screenshot), and confirm the Paid Apps Agreement is active.

**Code-side audit — everything is wired correctly:**
- RevenueCat SDK is installed via Swift Package Manager ✅
- Configured at app launch with the test key in Debug builds and the production key in Release/TestFlight builds ✅
- Entitlement identifier `premium` is used consistently across the paywall, settings, journal, onboarding, and streak shield logic ✅
- Purchase, restore, and live customer-info listening are all implemented correctly ✅
- The paywall correctly handles cancellation, pending payment, and dismisses on successful purchase ✅

**Two small improvements worth making:**
1. Build number is still 1 — needs to be 10 (Apple already used 9).
2. The paywall shows raw RevenueCat error text in the alert. We'll translate a few common error codes (configuration/products not available, network, store problems) into friendly, plain-English messages so future issues feel less broken to users.

## What I'll change

- **Bump version to 1.0.1 and build number to 10** across all targets so a fresh build can be uploaded to TestFlight.
- **Friendlier purchase error messages** on the paywall — if products fail to load or a purchase errors due to store configuration, show a clear "Subscriptions are temporarily unavailable, please try again shortly" instead of a raw technical message. Cancellations stay silent (already correct).
- **Re-fetch offerings when the paywall opens** if they failed initially, so a transient load failure doesn't leave the paywall blank.

## What you need to do (outside the app)

1. Open each subscription in App Store Connect and clear the "Developer Action Needed" banner — fill in the missing localization, description, or review screenshot it asks for.
2. Confirm the Paid Apps Agreement is active under Business → Agreements.
3. Make sure both products are attached to the next review submission.
4. After I push build 10, upload it to TestFlight and submit for review.

Once you approve, I'll make the changes and rebuild.