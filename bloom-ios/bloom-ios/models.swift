//
//  models.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/1/26.
//

import SwiftUI
import Combine

// MARK: - Enums

enum UserRole: String, Codable, CaseIterable {
    case mom     = "mom"
    case partner = "partner"
}

enum DeliveryType: String, Codable, CaseIterable {
    case vaginal  = "vaginal"
    case cesarean = "cesarean"
}

enum RecoveryStage: String, Codable, CaseIterable {
    case week1  = "week_1"
    case week2  = "week_2"
    case week3  = "week_3"
    case week4  = "week_4"
    case week6  = "week_6"
    case week8  = "week_8"
    case week10 = "week_10"
    case week12 = "week_12"

    var label: String {
        switch self {
        case .week1:  return "Week 1"
        case .week2:  return "Week 2"
        case .week3:  return "Week 3"
        case .week4:  return "Week 4"
        case .week6:  return "Week 6"
        case .week8:  return "Week 8"
        case .week10: return "Week 10"
        case .week12: return "Week 12+"
        }
    }
}

enum Mood: String, Codable, CaseIterable {
    case great   = "great"
    case good    = "good"
    case okay    = "okay"
    case low     = "low"
    case anxious = "anxious"
    case sad     = "sad"

    var emoji: String {
        switch self {
        case .great:   return "😊"
        case .good:    return "🙂"
        case .okay:    return "😐"
        case .low:     return "😔"
        case .anxious: return "😰"
        case .sad:     return "😢"
        }
    }

    var color: Color {
        switch self {
        case .great:   return Color(red: 0.2,  green: 0.8,  blue: 0.5)
        case .good:    return Color(red: 0.4,  green: 0.85, blue: 0.4)
        case .okay:    return Color(red: 0.95, green: 0.8,  blue: 0.2)
        case .low:     return Color(red: 0.95, green: 0.55, blue: 0.2)
        case .anxious: return Color(red: 0.9,  green: 0.4,  blue: 0.3)
        case .sad:     return Color(red: 0.6,  green: 0.3,  blue: 0.5)
        }
    }
}

enum BloomPillar: String, Codable {
    case mind    = "mind"
    case body    = "body"
    case baby    = "baby"
    case partner = "partner"
}

// MARK: - Data Types

struct MoodEntry: Codable {
    let mood: Mood
    let note: String
    let timestamp: Double   // Unix — no date formatting issues

    init(mood: Mood, note: String = "") {
        self.mood = mood
        self.note = note
        self.timestamp = Date().timeIntervalSince1970
    }

    var date: Date { Date(timeIntervalSince1970: timestamp) }
    var hoursAgo: Double { Date().timeIntervalSince(date) / 3600.0 }
}

struct BabyData: Codable {
    var babyName: String = ""
    var ageInDays: Int = 0
    var lastFeedHoursAgo: Double = 0
    var lastSleepHoursAgo: Double = 0
    var currentStatus: String = "unknown"   // "sleeping", "awake", "fussy"
}

// MARK: - UserProfile (singleton, persisted to UserDefaults)

class UserProfile: ObservableObject {
    static let shared = UserProfile()

    @Published var role: UserRole = .mom
    @Published var deliveryType: DeliveryType = .vaginal
    @Published var recoveryStage: RecoveryStage = .week1
    @Published var babyData: BabyData = BabyData()
    @Published var moodHistory: [MoodEntry] = []
    @Published var onboardingComplete: Bool = false

    private let key = "bloom_profile"

    init() {
        load()
    }

    // MARK: - Persistence

    func save() {
        let raw: [String: Any] = [
            "role": role.rawValue,
            "deliveryType": deliveryType.rawValue,
            "recoveryStage": recoveryStage.rawValue,
            "onboardingComplete": onboardingComplete,
            "babyData": [
                "babyName": babyData.babyName,
                "ageInDays": babyData.ageInDays,
                "lastFeedHoursAgo": babyData.lastFeedHoursAgo,
                "lastSleepHoursAgo": babyData.lastSleepHoursAgo,
                "currentStatus": babyData.currentStatus
            ] as [String: Any],
            "moodHistory": moodHistory.map { [
                "mood": $0.mood.rawValue,
                "note": $0.note,
                "timestamp": $0.timestamp
            ] as [String: Any] }
        ]
        if let data = try? JSONSerialization.data(withJSONObject: raw) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }

        role              = UserRole(rawValue: dict["role"] as? String ?? "") ?? .mom
        deliveryType      = DeliveryType(rawValue: dict["deliveryType"] as? String ?? "") ?? .vaginal
        recoveryStage     = RecoveryStage(rawValue: dict["recoveryStage"] as? String ?? "") ?? .week1
        onboardingComplete = dict["onboardingComplete"] as? Bool ?? false

        if let bd = dict["babyData"] as? [String: Any] {
            babyData = BabyData(
                babyName:            bd["babyName"] as? String ?? "",
                ageInDays:           bd["ageInDays"] as? Int ?? 0,
                lastFeedHoursAgo:    bd["lastFeedHoursAgo"] as? Double ?? 0,
                lastSleepHoursAgo:   bd["lastSleepHoursAgo"] as? Double ?? 0,
                currentStatus:       bd["currentStatus"] as? String ?? "unknown"
            )
        }

        if let arr = dict["moodHistory"] as? [[String: Any]] {
            moodHistory = arr.compactMap { entry in
                guard let mood = Mood(rawValue: entry["mood"] as? String ?? ""),
                      let ts = entry["timestamp"] as? Double else { return nil }
                var e = MoodEntry(mood: mood, note: entry["note"] as? String ?? "")
                return e
            }
        }
    }

    // MARK: - Mutations

    func addMoodEntry(_ mood: Mood, note: String = "") {
        moodHistory.append(MoodEntry(mood: mood, note: note))
        if moodHistory.count > 7 { moodHistory = Array(moodHistory.suffix(7)) }
        save()
    }

    // MARK: - Context for server

    func contextForServer() -> [String: Any] {
        return [
            "user_role": role.rawValue,
            "delivery_type": deliveryType.rawValue,
            "recovery_stage": recoveryStage.rawValue,
            "baby": [
                "name": babyData.babyName,
                "age_days": babyData.ageInDays,
                "last_feed_hours_ago": babyData.lastFeedHoursAgo,
                "last_sleep_hours_ago": babyData.lastSleepHoursAgo,
                "current_status": babyData.currentStatus
            ] as [String: Any],
            "mood_history": moodHistory.map { [
                "mood": $0.mood.rawValue,
                "note": $0.note,
                "hours_ago": $0.hoursAgo
            ] as [String: Any] }
        ]
    }
}

// MARK: - Server Response shapes

struct BloomResponse: Codable {
    let pillar:          BloomPillar
    let title:           String
    let content:         String
    let suggestion:      String?
    let exerciseSteps:   [String]?
    let partnerActions:  [String]?
    let moodInsight:     String?
    let babyReadout:     BabyReadout?
    let breathing:       BreathingExercise?
}

struct BabyReadout: Codable {
    let likelyState: String      // "hungry", "tired", "comfortable", "fussy"
    let confidence:  String      // "high", "medium", "low"
    let guidance:    String
}

struct BreathingExercise: Codable {
    let name:        String
    let inhaleSecs:  Int
    let holdSecs:    Int
    let exhaleSecs:  Int
    let rounds:      Int
}
