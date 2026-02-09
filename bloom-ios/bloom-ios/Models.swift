//
//  Models.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/8/26.
//

import Foundation
import SwiftUI

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

enum MilestoneCategory {
    case physical
    case emotional
    case sleep
    case baby
    case relationship
}

// MARK: - Data Models

struct BabyData {
    var babyName: String = "Baby Leo"
    var babyAgeWeeks: Int = 3
    var lastFeedHoursAgo: Double = 2.5
    var currentStatus: String = "sleeping"
    
    // Growth stats
    var birthWeight: Double = 7.2
    var currentWeight: Double = 8.4
    var birthLength: Double = 19.5
    var currentLength: Double = 21.0
    var weightPercentile: Int = 45
    var lengthPercentile: Int = 52
    
    // Daily tracking
    var feedsToday: Int = 8
    var sleepHoursToday: Double = 14.5
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

struct Appointment: Identifiable {
    let id = UUID()
    let title: String
    let type: AppointmentType
    let date: Date
    let time: String?
    let location: String?
    let provider: String?
    let notes: String?
    
    init(
        title: String,
        type: AppointmentType,
        date: Date,
        time: String? = nil,
        location: String? = nil,
        provider: String? = nil,
        notes: String? = nil
    ) {
        self.title = title
        self.type = type
        self.date = date
        self.time = time
        self.location = location
        self.provider = provider
        self.notes = notes
    }
}

enum AppointmentType: String {
    case postpartumCheckup = "Postpartum Checkup"
    case pediatricCheckup = "Pediatric Checkup"
    case lactationConsult = "Lactation Consultation"
    case mentalHealth = "Mental Health"
    case physicalTherapy = "Physical Therapy"
    
    var icon: String {
        switch self {
        case .postpartumCheckup: return "heart.text.square.fill"
        case .pediatricCheckup: return "heart.fill"
        case .lactationConsult: return "drop.fill"
        case .mentalHealth: return "brain.fill"
        case .physicalTherapy: return "figure.walk"
        }
    }
    
    var color: Color {
        switch self {
        case .postpartumCheckup: return Color(red: 0.94, green: 0.25, blue: 0.37)
        case .pediatricCheckup: return Color(red: 0.2, green: 0.7, blue: 0.5)
        case .lactationConsult: return Color(red: 0.53, green: 0.81, blue: 0.98)
        case .mentalHealth: return Color(red: 0.65, green: 0.45, blue: 0.95)
        case .physicalTherapy: return Color(red: 0.95, green: 0.78, blue: 0.25)
        }
    }
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
