//
//  UserProfile.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/8/26.
//


//
//  UserProfile.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/8/26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - User Profile

class UserProfile: ObservableObject {
    static let shared = UserProfile()
    
    @Published var onboardingComplete: Bool = false
    @Published var role: UserRole = .mom
    @Published var deliveryType: DeliveryType = .vaginal
    @Published var deliveryDate: Date = Calendar.current.date(byAdding: .weekOfYear, value: -3, to: Date())!
    @Published var babyData: BabyData = BabyData()
    @Published var moodHistory: [MoodEntry] = []
    @Published var sleepHistory: [SleepEntry] = []
    @Published var milestones: [Milestone] = []
    
    var recoveryStage: RecoveryStage {
        let weeks = weeksPostpartum
        if weeks < 1 { return .immediate }
        if weeks < 2 { return .early }
        if weeks < 6 { return .active }
        return .extended
    }
    
    var weeksPostpartum: Int {
        let days = Calendar.current.dateComponents([.day], from: deliveryDate, to: Date()).day ?? 0
        return days / 7
    }
    
    init() {
        loadMockData()
    }
    
    func addMoodEntry(_ mood: Mood, note: String) {
        let entry = MoodEntry(mood: mood, note: note, timestamp: Date())
        moodHistory.append(entry)
    }
    
    func contextForServer() -> [String: Any] {
        [
            "role": role.rawValue,
            "delivery_type": deliveryType.rawValue,
            "weeks_postpartum": weeksPostpartum,
            "baby_name": babyData.babyName,
            "baby_age_weeks": babyData.babyAgeWeeks,
            "recent_mood": moodHistory.last?.mood.rawValue ?? "none",
            "sleep_quality": averageSleepQuality
        ]
    }
    
    var averageSleepQuality: Double {
        guard !sleepHistory.isEmpty else { return 0 }
        let total = sleepHistory.reduce(0.0) { $0 + $1.quality }
        return total / Double(sleepHistory.count)
    }
    
    func save() {
        // Persist to UserDefaults or elsewhere
        onboardingComplete = true
    }
    
    // MARK: - Mock Data Generation
    
    private func loadMockData() {
        generateMockMoodHistory()
        generateMockSleepHistory()
        generateMockMilestones()
    }
    
    private func generateMockMoodHistory() {
        let moods: [Mood] = [.calm, .hopeful, .overwhelmed, .anxious, .grateful, .calm, .hopeful]
        let notes = [
            "Feeling better today",
            "Had a good morning",
            "Rough night but managing",
            "",
            "Grateful for support",
            "Things are looking up",
            ""
        ]
        
        for i in 0..<14 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            let mood = moods[i % moods.count]
            let note = i < notes.count ? notes[i] : ""
            
            moodHistory.insert(
                MoodEntry(mood: mood, note: note, timestamp: date),
                at: 0
            )
        }
    }
    
    private func generateMockSleepHistory() {
        let hours = [6.5, 5.8, 6.2, 7.0, 5.5, 6.8, 6.3, 7.2, 6.0, 6.5, 6.8, 5.9, 6.4, 7.0]
        let qualities = [0.7, 0.6, 0.68, 0.78, 0.55, 0.72, 0.7, 0.8, 0.65, 0.7, 0.75, 0.63, 0.71, 0.78]
        let wakings = [4, 5, 3, 3, 5, 3, 4, 2, 4, 3, 3, 4, 3, 2]
        
        for i in 0..<14 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            
            sleepHistory.insert(
                SleepEntry(
                    date: date,
                    hours: hours[i],
                    quality: qualities[i],
                    nightWakings: wakings[i]
                ),
                at: 0
            )
        }
    }
    
    private func generateMockMilestones() {
        milestones = [
            Milestone(
                title: "First walk outside",
                description: "15 minutes around the block",
                date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
                category: .physical,
                icon: "figure.walk"
            ),
            Milestone(
                title: "Full night's sleep",
                description: "7 hours uninterrupted",
                date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                category: .sleep,
                icon: "moon.stars.fill"
            ),
            Milestone(
                title: "Feeling like yourself",
                description: "First time since delivery",
                date: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                category: .emotional,
                icon: "sparkles"
            ),
            Milestone(
                title: "Started pelvic floor exercises",
                description: "Cleared by doctor",
                date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
                category: .physical,
                icon: "figure.strengthtraining.traditional"
            )
        ].sorted { $0.date > $1.date }
    }
}

// MARK: - Enums

enum UserRole: String, Codable {
    case mom
    case partner
}

enum DeliveryType: String, Codable {
    case vaginal
    case cesarean
}

enum RecoveryStage {
    case immediate  // 0-1 week
    case early      // 1-2 weeks
    case active     // 2-6 weeks
    case extended   // 6+ weeks
    
    var label: String {
        switch self {
        case .immediate: return "Week 1"
        case .early: return "Week 2"
        case .active: return "Weeks 3-6"
        case .extended: return "6+ Weeks"
        }
    }
}

enum Mood: String, CaseIterable {
    case happy
    case calm
    case sad
    case anxious
    case overwhelmed
    case hopeful
    case grateful
    case lonely
    case angry
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .calm: return "😌"
        case .sad: return "😢"
        case .anxious: return "😰"
        case .overwhelmed: return "😓"
        case .hopeful: return "🌟"
        case .grateful: return "🙏"
        case .lonely: return "😔"
        case .angry: return "😠"
        }
    }
    
    var color: Color {
        switch self {
        case .happy: return Color(red: 0.95, green: 0.78, blue: 0.25)
        case .calm: return Color(red: 0.53, green: 0.81, blue: 0.98)
        case .sad: return Color(red: 0.65, green: 0.45, blue: 0.95)
        case .anxious: return Color(red: 0.94, green: 0.5, blue: 0.37)
        case .overwhelmed: return Color(red: 0.94, green: 0.25, blue: 0.37)
        case .hopeful: return Color(red: 0.95, green: 0.78, blue: 0.65)
        case .grateful: return Color(red: 0.2, green: 0.7, blue: 0.5)
        case .lonely: return Color(red: 0.6, green: 0.6, blue: 0.7)
        case .angry: return Color(red: 0.9, green: 0.3, blue: 0.3)
        }
    }
}

enum BloomPillar: String, Codable {
    case mind
    case body
    case baby
    case partner
}

// MARK: - Data Models

struct BabyData {
    var babyName: String = "Baby"
    var babyAgeWeeks: Int = 3
    var lastFeedHoursAgo: Double = 2.5
    var currentStatus: String = "sleeping"
}

struct MoodEntry: Identifiable {
    let id = UUID()
    let mood: Mood
    let note: String
    let timestamp: Date
}

struct SleepEntry: Identifiable {
    let id = UUID()
    let date: Date
    let hours: Double
    let quality: Double  // 0.0 to 1.0
    let nightWakings: Int
}

struct Milestone: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let date: Date
    let category: MilestoneCategory
    let icon: String
}

enum MilestoneCategory {
    case physical
    case emotional
    case sleep
    case baby
    case relationship
}

// MARK: - Server Response Models

struct BloomResponse: Codable {
    let pillar: BloomPillar
    let title: String
    let content: String
    let suggestion: String?
    let breathing: BreathingExercise?
    let moodInsight: String?
    let exerciseSteps: [String]?
    let babyReadout: BabyReadout?
    let partnerActions: [String]?
}

struct BreathingExercise: Codable {
    let name: String
    let inhaleSecs: Int
    let holdSecs: Int
    let exhaleSecs: Int
    let rounds: Int
}

struct BabyReadout: Codable {
    let likelyState: String
    let confidence: String
    let guidance: String
}
