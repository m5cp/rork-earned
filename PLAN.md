# Paywall: rename Yearly → Annual, add free trial badge, add offer code redemption

**Changes to the paywall**

- Rename the "Yearly" plan label to **Annual** everywhere it appears.
- Under the Annual plan price, add a small green badge / line that reads **"Free trial available"** (only shown on the Annual card). 
- Add a **"Redeem Offer Code"** button in the paywall footer, placed right next to **Restore Purchases** (both shown as small subtle text links above the legal text). This is the standard iOS placement and keeps the main pricing section clean and focused.
- Tapping "Redeem Offer Code" opens Apple's native offer code redemption sheet (the system sheet handled by StoreKit). After a successful redemption, the user's subscription state refreshes automatically.

**Why the footer for the offer code**

Putting it in the footer (alongside Restore Purchases) is the convention used by most premium iOS apps (Things, Bear, Streaks, etc.). It stays out of the way for normal buyers but is easy to find for anyone who has a code. Putting it above the Continue button would distract from the primary purchase flow and is generally discouraged by Apple's HIG.

**Note on the trial**

The "Free trial available" badge will display whenever the Annual product has an introductory offer configured in App Store Connect. Once you set up the free trial in App Store Connect, it shows up automatically — no additional code change needed after this one.