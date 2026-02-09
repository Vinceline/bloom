//
//  MomView.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/8/26.
//


//
//  MomView.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/8/26.
//

import SwiftUI

struct MomView: View {
    @EnvironmentObject var profile: UserProfile
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Header with back button
                headerWithBack(
                    "Mom's Recovery",
                    icon: "heart.fill",
                    color: Color(red: 0.94, green: 0.25, blue: 0.37)
                )
                
                // Recovery overview
                recoveryOverviewCard()
                
                // Current mood & wellbeing
                moodWellbeingCard()
                
                // Physical recovery
                physicalRecoveryCard()
                
                // Sleep tracking
                sleepTrackingCard()
                
                // What to watch for
                watchForCard()
                
                // Support tips
                supportTipsCard()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color.black)
    }
    
    // MARK: - Recovery Overview
    
    private func recoveryOverviewCard() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("RECOVERY STAGE")
                        .font(.system(size: 10, weight: .bold))
                        .kerning(1)
                        .foregroundColor(Color(.sRGB, red: 0.45, green: 0.45, blue: 0.5))
                    
                    Text(profile.recoveryStage.label)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("\(profile.weeksPostpartum) weeks postpartum")
                        .font(.system(size: 13))
                        .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25), lineWidth: 6)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: progressPercentage)
                        .stroke(Color(red: 0.94, green: 0.25, blue: 0.37), lineWidth: 6)
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(progressPercentage * 100))%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            Divider()
                .background(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25))
            
            // Quick stats
            HStack(spacing: 20) {
                quickStat(
                    icon: "heart.fill",
                    value: recentMoodEmoji,
                    label: "Latest mood"
                )
                
                quickStat(
                    icon: "moon.stars.fill",
                    value: "\(profile.averageSleepHours, default: "%.1f")h",
                    label: "Avg sleep"
                )
                
                quickStat(
                    icon: "checkmark.circle.fill",
                    value: "\(profile.moodHistory.count)",
                    label: "Check-ins"
                )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                .stroke(
                    Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                    lineWidth: 1
                )
        )
    }
    
    private func quickStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.94, green: 0.25, blue: 0.37))
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Mood & Wellbeing
    
    private func moodWellbeingCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood & Wellbeing")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                // Recent mood trend
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recent trend")
                            .font(.system(size: 12))
                            .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
                        
                        HStack(spacing: 6) {
                            ForEach(recentMoods.suffix(5), id: \.id) { entry in
                                Text(entry.mood.emoji)
                                    .font(.system(size: 20))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Overall indicator
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10))
                            Text("Improving")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(Color(red: 0.24, green: 0.8, blue: 0.5))
                        
                        Text("Overall")
                            .font(.system(size: 10))
                            .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
                    }
                }
                
                if let lastEntry = profile.moodHistory.last, !lastEntry.note.isEmpty {
                    Divider()
                        .background(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Latest note")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
                        
                        Text("\"\(lastEntry.note)\"")
                            .font(.system(size: 13))
                            .foregroundColor(Color(.sRGB, red: 0.7, green: 0.7, blue: 0.75))
                            .italic()
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                    .stroke(
                        Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                        lineWidth: 1
                    )
            )
        }
    }
    
    // MARK: - Physical Recovery
    
    private func physicalRecoveryCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Physical Recovery")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                recoveryItem(
                    label: "Delivery type",
                    value: profile.deliveryType == .cesarean ? "C-section" : "Vaginal",
                    icon: "cross.case.fill"
                )
                
                recoveryItem(
                    label: "Pain level",
                    value: "Mild (improving)",
                    icon: "heart.text.square.fill",
                    trend: .improving
                )
                
                recoveryItem(
                    label: "Mobility",
                    value: "Good",
                    icon: "figure.walk",
                    trend: .improving
                )
                
                recoveryItem(
                    label: "Bleeding",
                    value: "Moderate (normal)",
                    icon: "drop.fill"
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                    .stroke(
                        Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                        lineWidth: 1
                    )
            )
        }
    }
    
    private func recoveryItem(
        label: String,
        value: String,
        icon: String,
        trend: RecoveryTrend? = nil
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.94, green: 0.25, blue: 0.37))
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color(.sRGB, red: 0.6, green: 0.6, blue: 0.65))
            
            Spacer()
            
            HStack(spacing: 6) {
                Text(value)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                
                if let trend = trend {
                    Image(systemName: trend == .improving ? "arrow.up.right" : "arrow.right")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 0.24, green: 0.8, blue: 0.5))
                }
            }
        }
    }
    
    // MARK: - Sleep Tracking
    
    private func sleepTrackingCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sleep Patterns")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Average sleep")
                            .font(.system(size: 12))
                            .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
                        
                        Text("\(profile.averageSleepHours, specifier: "%.1f") hours/night")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10))
                            Text("+0.8h")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(Color(red: 0.24, green: 0.8, blue: 0.5))
                        
                        Text("vs last week")
                            .font(.system(size: 10))
                            .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
                    }
                }
                
                Divider()
                    .background(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25))
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sleep quality")
                            .font(.system(size: 12))
                            .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
                        
                        Text("\(Int(profile.averageSleepQuality * 100))%")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Night wakings")
                            .font(.system(size: 12))
                            .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
                        
                        Text("3.2 avg")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                    .stroke(
                        Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                        lineWidth: 1
                    )
            )
        }
    }
    
    // MARK: - Watch For
    
    private func watchForCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color(red: 0.95, green: 0.78, blue: 0.25))
                
                Text("What to watch for")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                watchItem("Heavy bleeding (soaking more than 1 pad/hour)")
                watchItem("Severe headache or vision changes")
                watchItem("Signs of infection (fever, foul-smelling discharge)")
                watchItem("Chest pain or difficulty breathing")
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.2, green: 0.15, blue: 0.05))
                    .stroke(
                        Color(red: 0.95, green: 0.78, blue: 0.25, opacity: 0.3),
                        lineWidth: 1
                    )
            )
            
            Text("Call healthcare provider immediately if any of these occur")
                .font(.system(size: 11))
                .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
        }
    }
    
    private func watchItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color(red: 0.95, green: 0.78, blue: 0.25))
                .frame(width: 6, height: 6)
                .padding(.top, 5)
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(Color(.sRGB, red: 0.7, green: 0.7, blue: 0.75))
        }
    }
    
    // MARK: - Support Tips
    
    private func supportTipsCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color(red: 0.53, green: 0.81, blue: 0.98))
                
                Text("How you can help")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                tipItem("Encourage rest - offer to take baby so she can sleep")
                tipItem("Help with household tasks without being asked")
                tipItem("Bring nutritious meals and plenty of water")
                tipItem("Listen without trying to fix everything")
                tipItem("Watch for signs of postpartum depression")
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                    .stroke(
                        Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                        lineWidth: 1
                    )
            )
        }
    }
    
    private func tipItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.24, green: 0.8, blue: 0.5))
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(Color(.sRGB, red: 0.7, green: 0.7, blue: 0.75))
        }
    }
    
    // MARK: - Helpers
    
    private var progressPercentage: Double {
        let weeks = Double(profile.weeksPostpartum)
        return min(weeks / 6.0, 1.0)
    }
    
    private var recentMoodEmoji: String {
        profile.moodHistory.last?.mood.emoji ?? "—"
    }
    
    private var recentMoods: [MoodEntry] {
        Array(profile.moodHistory.suffix(7))
    }
}

enum RecoveryTrend {
    case improving
    case stable
}

#Preview {
    ScrollView {
        MomView()
    }
    .background(Color.black)
    .environmentObject(UserProfile.shared)
}
