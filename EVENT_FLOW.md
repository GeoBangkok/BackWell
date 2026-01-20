# Facebook Event Flow - BackWell Free Trial Funnel

## Your Funnel (HARD-GATED Paywall + 3-Day Free Trial)

```
Onboarding → Paywall Shown → User MUST Choose:
  ├─ Purchase Now → Paid User (Days 1-28 unlocked) → Enter App
  └─ Start Free Trial → Trial User (Days 1-3 free) → Enter App
      └─ Day 4+ → Must Purchase to Continue

IF USER DISMISSES: They never enter app (bounce)
```

**Key Insight:** StartTrial is your hard-gate activation event.
- If someone doesn't fire StartTrial OR Purchase, they bounced
- StartTrial = "real user acquired"

---

## Event Sequence (Step-by-Step)

### **1. Onboarding Complete**

**Location:** `OnboardingView.swift:154`

**Fires:**
```swift
FacebookEventTracker.shared.trackCompleteRegistration()
```

**Event:** `CompleteRegistration`
**Parameters:**
- `registration_method`: "onboarding"
- `subscription_status`: "inactive"

**Meaning:** User finished the onboarding flow (pain assessment, conditions, etc.)

---

### **2. Paywall Shown**

**Location:** `AppRootView.swift:44-48`

**Fires:**
```swift
FacebookEventTracker.shared.trackPaywallViewed(
    placement: "onboarding_complete",
    paywallID: "primary_paywall",
    currentDay: nil
)
```

**Event:** `InitiatedCheckout` (paywall viewed)
**Parameters:**
- `placement`: "onboarding_complete"
- `paywallID`: "primary_paywall"
- **NO valueToSum** (this is not a money event)

**Meaning:** User reached the paywall (money moment)

**Optimization:** Use this for Phase 1a if purchase volume is low

---

### **3a. User Dismisses Paywall WITHOUT Purchase**

**Location:** `AppRootView.swift:64-67`

**Fires:**
```swift
FacebookEventTracker.shared.trackStartTrial()
```

**Event:** `StartTrial`
**Parameters:**
- `trial_length_days`: 3
- `trial_end_day`: 3
- `subscription_status`: "trial"
- `current_day`: 0
- `content_type`: "trial_started"

**Meaning:** User entered free trial mode (can access Days 1-3 without paying)

**Optimization:** Best optimization event for Phase 1 (better than Paywall Viewed)

---

### **3b. User Purchases from Initial Paywall**

**Location:** `StoreManager.swift:68-95`

**Fires:**
```swift
// Always fires
FacebookEventTracker.shared.trackPurchase(
    productID: "backwell_unlimited_weekly_9_99",
    price: 9.99,
    currency: "USD",
    currentDay: nil,
    isRenewal: false
)

// Only fires ONCE per user (first purchase ever)
FacebookEventTracker.shared.trackSubscribe(
    productID: "backwell_unlimited_weekly_9_99",
    price: 9.99,
    currentDay: nil
)
```

**Event 1:** `Purchase`
**Parameters:**
- `productID`: "backwell_unlimited_weekly_9_99"
- `price`: 9.99
- `currency`: "USD"
- `is_renewal`: false
- `subscription_status`: "active"

**Event 2:** `Subscribe` (first purchase only)
**Parameters:**
- `productID`: "backwell_unlimited_weekly_9_99"
- `price`: 9.99
- `subscription_tier`: "unlimited_weekly"
- `is_first_purchase`: true

**Meaning:** User purchased immediately from onboarding paywall

**Optimization:** PRIMARY money event for Phase 2

---

### **4. Paywall Dismissed (Either Way)**

**Location:** `AppRootView.swift:58-61`

**Fires:**
```swift
FacebookEventTracker.shared.trackPaywallDismissed(
    hadPurchase: true/false,
    timeOnPaywall: <seconds>
)
```

**Event:** `paywall_dismissed` (custom)
**Parameters:**
- `had_purchase`: true or false
- `exit_reason`: "purchased" or "dismissed"
- `time_on_paywall_seconds`: Time spent viewing

**Meaning:** Diagnostic event for understanding paywall behavior

---

### **5. User Completes Day 1 Routine**

**Location:** `HomeView.swift:181-188`

**Fires:**
```swift
FacebookEventTracker.shared.trackActivation(
    currentDay: 1,
    sessionLengthSeconds: <seconds>,
    subscriptionStatus: "trial" or "active"
)
```

**Event:** `activation` (custom)
**Parameters:**
- `current_day`: 1
- `session_length_seconds`: Time from start to finish
- `subscription_status`: "trial" (if free) or "active" (if paid)
- `content_type`: "first_routine_complete"

**Meaning:** User FINISHED their first workout routine (not just tapped it)

**Optimization:** BEST quality event for Phase 1b
- 2-4x better CVR to Purchase than Paywall Viewed
- Shows real engagement, not just browsing

---

### **6. User Tries to Access Day 4+ (No Subscription)**

**Location:** `HomeView.swift:94-97`

**Fires:**
```swift
FacebookEventTracker.shared.trackSubscriptionPrompt(
    day: 4,
    triggerPoint: "day_card_tap"
)
```

**Event:** `subscription_required_shown` (custom)
**Parameters:**
- `day`: Which day they tried to access
- `trigger_point`: "day_card_tap"
- `subscription_status`: "inactive"

**Meaning:** User hit the hard paywall (free trial ended)

**Also Shows:** Another paywall opportunity (could fire `InitiatedCheckout` again if you show paywall)

---

### **7. Trial Converts to Purchase (Day 4+ Purchase)**

**Location:** `StoreManager.swift:68-95`

**Same as Event 3b (Purchase + Subscribe)**

**Fires:**
```swift
FacebookEventTracker.shared.trackPurchase(
    productID: "backwell_unlimited_weekly_9_99",
    price: 9.99,
    currency: "USD",
    currentDay: nil,
    isRenewal: false
)

// First purchase only
FacebookEventTracker.shared.trackSubscribe(...)
```

**Meaning:** Trial user converted to paid subscriber

---

### **8. Day 3, 7, 14, 28 Completed (Milestones)**

**Location:** `HomeView.swift:191-196`

**Fires:**
```swift
FacebookEventTracker.shared.trackAchievedLevel(
    day: 3/7/14/28,
    totalCompletedDays: <count>,
    subscriptionStatus: "active" or "trial"
)
```

**Event:** `AchievedLevel`
**Parameters:**
- `level`: "3", "7", "14", or "28"
- `milestone`: "trial_end", "week_1", "week_2", "program_complete"
- `total_completed_days`: Actual completion count
- `completion_rate`: Engagement metric
- `subscription_status`: "active" or "trial"

**Meaning:** User hit key retention milestone

**Optimization:** Use for long-term LTV lookalike audiences

---

### **9. Weekly Renewal**

**Location:** `StoreManager.swift:202-209`

**Fires:**
```swift
FacebookEventTracker.shared.trackPurchase(
    productID: "backwell_unlimited_weekly_9_99",
    price: 9.99,
    currency: "USD",
    currentDay: nil,
    isRenewal: true
)
```

**Event:** `Purchase`
**Parameters:**
- `is_renewal`: **true** (not first purchase)
- `subscription_status`: "active"

**Meaning:** Subscriber renewed for another week

**Note:** Subscribe does NOT fire on renewals (only first purchase)

---

## Meta Ads Optimization Strategy (Hard-Gated Funnel)

### **Phase 1: StartTrial (Week 1-3)**

**Optimize for: `StartTrial`**

- **Why:** Hard-gate activation event - filters bounces automatically
- **Volume:** Everyone who enters app fires this (high volume)
- **Quality:** Better than Paywall Viewed - shows commitment to try
- **Expected CPA:** $5-12 per trial start
- **Expected CVR to Purchase:** 15-30%
- **Budget:** $50-150/day

**This is your primary optimization event until you have real purchase volume.**

**When to switch:** Once you have 50+ Purchase events and stable CVR

---

### **Phase 1b: Activation (Optional - Quality Diagnostic)**

**Optimize for: `activation` (ONLY if StartTrial CVR is weak)**

- **Why:** Better quality predictor than StartTrial
- **Expected CPA:** $8-15 per activation
- **Expected CVR to Purchase:** 30-50% (2-4x better than StartTrial)
- **Use if:** StartTrial → Purchase CVR is <15%

**Don't use this unless StartTrial quality is terrible.**

---

### **Phase 2: Purchase (Week 3-4+)**

**Switch when:**
- You have 50+ Purchase events total
- Meta exits "Learning Limited" mode
- Purchase CVR is stable (±2% variance over 3 days)

**Optimize for:** `Purchase`
- Expected CPA: $20-50
- Expected ROAS (7-day): 1.5-3.0x
- Expected ROAS (30-day): 2.5-5.0x (with renewals)
- Budget: $100-500/day (scale gradually)

**Keep StartTrial campaign running at 10-20% budget for exploration.**

---

## 🔑 Key Metric: Purchase / StartTrial Ratio

**This is your truth.**

| Purchase/StartTrial Ratio | What It Means | Action |
|---------------------------|---------------|--------|
| >25% | Excellent trial quality | Scale spend aggressively |
| 15-25% | Good trial quality | Scale spend gradually |
| 10-15% | Weak trial quality | Fix onboarding or content |
| <10% | Broken trial experience | Don't scale - diagnose problem |

**Track this daily.** If ratio drops, you have a trial quality problem, not a targeting problem.

---

## Event Timing Summary

```
User Journey:          Facebook Events:
───────────────        ────────────────

Onboarding            → CompleteRegistration

Paywall Shown         → InitiatedCheckout (Paywall Viewed)

User Decides:
  ├─ Purchase         → Purchase + Subscribe (first only)
  │                   → paywall_dismissed (had_purchase: true)
  │
  └─ Dismiss          → StartTrial (free trial started)
                      → paywall_dismissed (had_purchase: false)

Main App:

Day 1 Complete        → activation (session_length tracked)

Day 3 Complete        → AchievedLevel (milestone: "trial_end")

Day 4 Access          → subscription_required_shown
(if no sub)             (then shows paywall → InitiatedCheckout again)

Purchase              → Purchase + Subscribe (first only)
(trial convert)

Day 7 Complete        → AchievedLevel (milestone: "week_1")
(if subscribed)

Day 14 Complete       → AchievedLevel (milestone: "week_2")

Day 28 Complete       → AchievedLevel (milestone: "program_complete")

Weekly Renewal        → Purchase (is_renewal: true)
(every 7 days)
```

---

## Clean Event Count (What Fires When)

**Typical Free Trial User:**
1. CompleteRegistration (onboarding done)
2. InitiatedCheckout (paywall shown)
3. StartTrial (dismissed without purchase)
4. paywall_dismissed (no purchase)
5. activation (Day 1 complete)
6. AchievedLevel (Day 3 complete - trial ends)
7. subscription_required_shown (tried Day 4)
8. InitiatedCheckout (paywall shown again)
9. Purchase (converted!)
10. Subscribe (first purchase)
11. AchievedLevel (Day 7, 14, 28)
12. Purchase (weekly renewals, is_renewal: true)

**Typical Immediate Purchase User:**
1. CompleteRegistration (onboarding done)
2. InitiatedCheckout (paywall shown)
3. Purchase (bought immediately)
4. Subscribe (first purchase)
5. paywall_dismissed (with purchase)
6. activation (Day 1 complete, subscription_status: "active")
7. AchievedLevel (Day 3, 7, 14, 28)
8. Purchase (weekly renewals, is_renewal: true)

---

## What to Optimize For (Decision Tree)

```
Do you have >10 purchases/day?
├─ YES → Optimize for Purchase (Phase 2)
└─ NO  →
    Do you have >20 StartTrial events/day?
    ├─ YES →
    │   Is StartTrial → Purchase CVR >20%?
    │   ├─ YES → Optimize for StartTrial (Phase 1 - volume)
    │   └─ NO  → Optimize for activation (Phase 1b - quality)
    └─ NO  →
        Do you have >10 activation events/day?
        ├─ YES → Optimize for activation (Phase 1b)
        └─ NO  → Optimize for InitiatedCheckout (Phase 1a - bootstrap)
```

---

## Code Locations Reference

| Event | File | Line | Function |
|-------|------|------|----------|
| CompleteRegistration | OnboardingView.swift | 154 | trackCompleteRegistration() |
| InitiatedCheckout | AppRootView.swift | 44-48 | trackPaywallViewed() |
| StartTrial | AppRootView.swift | 65 | trackStartTrial() |
| paywall_dismissed | AppRootView.swift | 58-61 | trackPaywallDismissed() |
| activation | HomeView.swift | 183-187 | trackActivation() |
| Purchase | StoreManager.swift | 68-74 | trackPurchase() |
| Subscribe | StoreManager.swift | 89-93 | trackSubscribe() |
| subscription_required_shown | HomeView.swift | 94-96 | trackSubscriptionPrompt() |
| AchievedLevel | HomeView.swift | 191-196 | trackAchievedLevel() |
| Purchase (renewal) | StoreManager.swift | 202-209 | trackPurchase() |

---

**Next Step:** Test the full flow in Events Manager before launching ads.
