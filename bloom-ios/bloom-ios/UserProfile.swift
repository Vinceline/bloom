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
    
    @Published var isLoggedIn: Bool = false
    @Published var onboardingComplete: Bool = false
    @Published var userName: String = ""
    @Published var role: UserRole = .mom
    @Published var deliveryType: DeliveryType = .vaginal
    @Published var deliveryDate: Date = Calendar.current.date(byAdding: .weekOfYear, value: -3, to: Date())!
    @Published var babyData: BabyData = BabyData()
    @Published var moodHistory: [MoodEntry] = []
    @Published var sleepHistory: [SleepEntry] = []
    @Published var milestones: [Milestone] = []
    @Published var upcomingAppointments: [Appointment] = []
    @Published var pastAppointments: [Appointment] = []
    
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
        // Don't load mock data automatically anymore
        // Will be loaded via loadDemoData() for existing users
    }
    
    func loadDemoData() {
        // Load all mock data for demo/existing user
        onboardingComplete = true
        role = .mom
        deliveryType = .vaginal
        deliveryDate = Calendar.current.date(byAdding: .weekOfYear, value: -3, to: Date())!
        babyData.babyName = "Baby Leo"
        
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
    
    var averageSleepHours: Double {
        guard !sleepHistory.isEmpty else { return 0 }
        let total = sleepHistory.reduce(0.0) { $0 + $1.hours }
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
        generateMockAppointments()
    }
    // Add these methods to UserProfile.swift:

    func logout() {
        isLoggedIn = false
        onboardingComplete = false
        userName = ""
        role = .mom
        moodHistory = []
        sleepHistory = []
        milestones = []
        upcomingAppointments = []
        pastAppointments = []
    }

    func loadMomDemoData() {
        userName = "Sarah"
        role = .mom
        deliveryType = .vaginal
        isLoggedIn = true
        onboardingComplete = true
        deliveryDate = Calendar.current.date(byAdding: .weekOfYear, value: -3, to: Date())!
        babyData.babyName = "Baby Leo"
        
        loadMockData()
    }

    func loadPartnerDemoData() {
        userName = "Michael"
        role = .partner
        deliveryType = .vaginal
        isLoggedIn = true
        onboardingComplete = true
        deliveryDate = Calendar.current.date(byAdding: .weekOfYear, value: -3, to: Date())!
        babyData.babyName = "Baby Leo"
        
        loadMockData()
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
    
    
    private func generateMockAppointments() {
        // Upcoming appointments
        upcomingAppointments = [
            Appointment(
                title: "Mom's 6-Week Checkup",
                type: .postpartumCheckup,
                date: Calendar.current.date(byAdding: .weekOfYear, value: 3, to: Date())!,
                time: "10:00 AM",
                location: "Women's Health Center",
                provider: "Dr. Sarah Johnson"
            ),
            Appointment(
                title: "\(babyData.babyName)'s 2-Month Checkup",
                type: .pediatricCheckup,
                date: Calendar.current.date(byAdding: .weekOfYear, value: 5, to: Date())!,
                time: "2:30 PM",
                location: "Pediatric Associates",
                provider: "Dr. Michael Chen"
            ),
            Appointment(
                title: "Lactation Consultant",
                type: .lactationConsult,
                date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
                time: "11:00 AM",
                location: "Breastfeeding Support Center",
                provider: "Lisa Martinez, IBCLC"
            )
        ].sorted { $0.date < $1.date }
        
        // Past appointments
        pastAppointments = [
            Appointment(
                title: "Mom's 2-Week Checkup",
                type: .postpartumCheckup,
                date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                time: "9:00 AM",
                location: "Women's Health Center",
                provider: "Dr. Sarah Johnson",
                notes: "Healing well. Discussed postpartum recovery exercises. Follow up in 4 weeks."
            ),
            Appointment(
                title: "\(babyData.babyName)'s First Checkup",
                type: .pediatricCheckup,
                date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
                time: "3:00 PM",
                location: "Pediatric Associates",
                provider: "Dr. Michael Chen",
                notes: "Weight: \(babyData.birthWeight) lbs at birth, now \(babyData.currentWeight) lbs. Gaining well. All measurements normal."
            )
        ].sorted { $0.date > $1.date }
    }
}

