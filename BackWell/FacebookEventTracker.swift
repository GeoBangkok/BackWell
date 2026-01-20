//
//  FacebookEventTracker.swift
//  BackWell
//
//  Created by standard on 1/20/26.
//

import Foundation
import FacebookCore

/// Centralized Facebook event tracking for BackWell
/// Optimizes for purchases and retention
class FacebookEventTracker {
    static let shared = FacebookEventTracker()

    private init() {}

    // MARK: - User Context Properties

    /// Get common parameters to attach to all events
    /// PRIVACY: Does NOT include sensitive health data
    private func getCommonParameters(
        currentDay: Int? = nil,
        subscriptionStatus: String? = nil
    ) -> [AppEvents.ParameterName: Any] {
        var params: [AppEvents.ParameterName: Any] = [:]

        if let currentDay = currentDay {
            params[AppEvents.ParameterName("current_day")] = currentDay
        }

        if let subscriptionStatus = subscriptionStatus {
            params[AppEvents.ParameterName("subscription_status")] = subscriptionStatus
        }

        return params
    }

    // MARK: - TIER 1: Critical Purchase Optimization Events

    /// Track when user completes registration/onboarding
    /// PRIVACY: Only tracks engagement depth, NOT specific health data
    func trackCompleteRegistration() {
        var params = getCommonParameters(subscriptionStatus: "inactive")

        params[AppEvents.ParameterName("registration_method")] = "onboarding"
        params[AppEvents.ParameterName("onboarding_completed")] = true

        AppEvents.shared.logEvent(
            .completedRegistration,
            parameters: params
        )

        print("📊 FB Event: CompleteRegistration")
    }

    /// Track when paywall is shown to user (InitiatedCheckout = Paywall Viewed)
    /// This is the PRIMARY optimization event for early campaigns with low purchase volume
    /// NO valueToSum - this is not a monetary event
    /// NO currentDay - paywall is shown before user starts program
    func trackPaywallViewed(
        placement: String,
        paywallID: String
    ) {
        var params = getCommonParameters()

        params[AppEvents.ParameterName("paywall_id")] = paywallID
        params[AppEvents.ParameterName("placement")] = placement
        params[AppEvents.ParameterName("paywall_trigger")] = placement

        AppEvents.shared.logEvent(
            .initiatedCheckout,
            parameters: params
        )

        print("📊 FB Event: InitiatedCheckout (Paywall Viewed) - placement: \(placement)")
    }

    /// Track successful purchase - CRITICAL for ROAS optimization
    /// currentDay is optional - only pass if user is in active program (Day 1+)
    /// Omit currentDay for onboarding purchases or renewals without day context
    func trackPurchase(
        productID: String,
        price: Double,
        currency: String = "USD",
        currentDay: Int? = nil,
        isRenewal: Bool = false
    ) {
        var params = getCommonParameters(
            currentDay: currentDay,
            subscriptionStatus: "active"
        )

        params[.contentID] = productID
        params[.contentType] = "product"
        params[.currency] = currency
        params[AppEvents.ParameterName("subscription_type")] = "weekly"
        params[AppEvents.ParameterName("is_renewal")] = isRenewal

        AppEvents.shared.logPurchase(
            amount: price,
            currency: currency,
            parameters: params
        )

        print("📊 FB Event: Purchase - $\(price) \(currency) - product: \(productID) - renewal: \(isRenewal)")
    }

    /// Track subscription start - FIRST PURCHASE ONLY (not renewals)
    /// Use this sparingly - Purchase is the primary money event
    /// currentDay is optional - only pass if user is in active program (Day 1+)
    /// Omit currentDay for onboarding purchases
    func trackSubscribe(
        productID: String,
        price: Double,
        currentDay: Int? = nil
    ) {
        var params = getCommonParameters(
            currentDay: currentDay,
            subscriptionStatus: "active"
        )

        params[.contentID] = productID
        params[.currency] = "USD"
        params[AppEvents.ParameterName("subscription_tier")] = "unlimited_weekly"
        params[AppEvents.ParameterName("is_first_purchase")] = true

        AppEvents.shared.logEvent(
            .subscribe,
            valueToSum: price,
            parameters: params
        )

        print("📊 FB Event: Subscribe - $\(price) - FIRST PURCHASE")
    }

    // MARK: - TIER 2: Critical Retention Optimization Events

    /// Track Activation - first routine completed (Day 1)
    /// This is the BEST early optimization event (better than paywall)
    /// Shows real product engagement, not just browsing
    /// Default status is "trial" since Days 1-3 are free
    func trackActivation(
        currentDay: Int = 1,
        sessionLengthSeconds: Int,
        subscriptionStatus: String = "trial" // Most users are in trial when completing Day 1
    ) {
        var params = getCommonParameters(
            currentDay: currentDay,
            subscriptionStatus: subscriptionStatus
        )

        params[AppEvents.ParameterName("session_length_seconds")] = sessionLengthSeconds
        params[.contentType] = "first_routine_complete"

        AppEvents.shared.logEvent(
            AppEvents.Name("activation"),
            parameters: params
        )

        print("📊 FB Event: Activation - day: \(currentDay) - session: \(sessionLengthSeconds)s")
    }

    /// Track when user successfully starts trial and enters app
    /// In gated paywall: user chose "Start Trial" (not purchase, not dismiss)
    /// Fires when user enters app with Days 1-3 free access granted
    func trackStartTrial() {
        var params = getCommonParameters(subscriptionStatus: "trial")
        // NO currentDay - this is trial activation, not a program day event

        params[AppEvents.ParameterName("trial_length_days")] = 3 // Days 1-3 are free
        params[AppEvents.ParameterName("trial_end_day")] = 3 // Trial ends after Day 3
        params[.contentType] = "trial_started"

        AppEvents.shared.logEvent(
            .startTrial,
            parameters: params
        )

        print("📊 FB Event: StartTrial - 3-day trial activated")
    }

    /// Track milestone achievements - strong retention signal
    func trackAchievedLevel(
        day: Int,
        totalCompletedDays: Int,
        subscriptionStatus: String
    ) {
        var params = getCommonParameters(
            currentDay: day,
            subscriptionStatus: subscriptionStatus
        )

        params[.level] = "\(day)"
        params[AppEvents.ParameterName("total_completed_days")] = totalCompletedDays
        params[AppEvents.ParameterName("completion_rate")] = Double(totalCompletedDays) / Double(day)

        // Add milestone context
        let milestone: String
        switch day {
        case 3: milestone = "trial_end"
        case 7: milestone = "week_1"
        case 14: milestone = "week_2"
        case 28: milestone = "program_complete"
        default: milestone = "day_\(day)"
        }
        params[AppEvents.ParameterName("milestone")] = milestone

        AppEvents.shared.logEvent(
            .achievedLevel,
            parameters: params
        )

        print("📊 FB Event: AchievedLevel - day: \(day) - milestone: \(milestone)")
    }

    // MARK: - TIER 3: Funnel Optimization Events

    /// Track content views throughout the funnel
    func trackViewContent(
        contentType: String,
        contentID: String? = nil,
        currentDay: Int? = nil
    ) {
        var params = getCommonParameters(currentDay: currentDay)

        params[.contentType] = contentType
        if let contentID = contentID {
            params[.contentID] = contentID
        }

        AppEvents.shared.logEvent(
            .viewedContent,
            parameters: params
        )

        print("📊 FB Event: ViewContent - type: \(contentType)")
    }

    /// Track onboarding step completion
    /// PRIVACY: Only tracks funnel progress, NOT health data
    func trackOnboardingStep(
        step: Int,
        totalSteps: Int
    ) {
        var params = getCommonParameters()

        params[AppEvents.ParameterName("step_number")] = step
        params[AppEvents.ParameterName("total_steps")] = totalSteps
        params[AppEvents.ParameterName("step_progress")] = Double(step) / Double(totalSteps)

        AppEvents.shared.logEvent(
            AppEvents.Name("onboarding_step_completed"),
            parameters: params
        )

        print("📊 FB Event: onboarding_step_completed - step: \(step)/\(totalSteps)")
    }

    /// Track exercise completion - deep engagement signal
    func trackExerciseCompleted(
        day: Int,
        exerciseIndex: Int,
        totalExercises: Int,
        exerciseName: String,
        duration: Int,
        subscriptionStatus: String
    ) {
        var params = getCommonParameters(
            currentDay: day,
            subscriptionStatus: subscriptionStatus
        )

        params[.contentType] = "exercise"
        params[.contentID] = exerciseName
        params[AppEvents.ParameterName("exercise_number")] = exerciseIndex + 1
        params[AppEvents.ParameterName("total_exercises")] = totalExercises
        params[AppEvents.ParameterName("duration_seconds")] = duration
        params[AppEvents.ParameterName("day_progress")] = Double(exerciseIndex + 1) / Double(totalExercises)

        AppEvents.shared.logEvent(
            AppEvents.Name("exercise_completed"),
            parameters: params
        )

        print("📊 FB Event: exercise_completed - day: \(day) - \(exerciseName)")
    }

    /// Track day completion (all exercises done)
    func trackDayCompleted(
        day: Int,
        totalCompletedDays: Int,
        subscriptionStatus: String
    ) {
        var params = getCommonParameters(
            currentDay: day,
            subscriptionStatus: subscriptionStatus
        )

        params[.contentType] = "day_program"
        params[.contentID] = "day_\(day)"
        params[AppEvents.ParameterName("total_completed_days")] = totalCompletedDays

        AppEvents.shared.logEvent(
            AppEvents.Name("day_completed"),
            parameters: params
        )

        print("📊 FB Event: day_completed - day: \(day)")
    }

    // MARK: - TIER 4: Churn Prevention Events

    /// Track when paywall is dismissed without purchase
    func trackPaywallDismissed(
        hadPurchase: Bool,
        timeOnPaywall: TimeInterval? = nil
    ) {
        var params: [AppEvents.ParameterName: Any] = [:]
        params[AppEvents.ParameterName("had_purchase")] = hadPurchase
        params[AppEvents.ParameterName("exit_reason")] = hadPurchase ? "purchased" : "dismissed"

        if let timeOnPaywall = timeOnPaywall {
            params[AppEvents.ParameterName("time_on_paywall_seconds")] = Int(timeOnPaywall)
        }

        AppEvents.shared.logEvent(
            AppEvents.Name("paywall_dismissed"),
            parameters: params
        )

        print("📊 FB Event: paywall_dismissed - purchased: \(hadPurchase)")
    }

    /// Track subscription required prompt shown
    func trackSubscriptionPrompt(
        day: Int,
        triggerPoint: String
    ) {
        var params = getCommonParameters(
            currentDay: day,
            subscriptionStatus: "inactive"
        )

        params[AppEvents.ParameterName("trigger_point")] = triggerPoint

        AppEvents.shared.logEvent(
            AppEvents.Name("subscription_required_shown"),
            parameters: params
        )

        print("📊 FB Event: subscription_required_shown - day: \(day) - trigger: \(triggerPoint)")
    }
}
