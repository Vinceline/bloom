

//
//  InsightsView.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/8/26.
//

import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject var profile: UserProfile
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Header
                header(
                    "Your Journey",
                    icon: "chart.line.uptrend.xyaxis",
                    color: Color(red: 0.53, green: 0.81, blue: 0.98)
                )
                
                // Recovery timeline
                recoveryTimeline()
                
                // Mood trends
                moodTrends()
                
                // Sleep patterns
                sleepPatterns()
                
                // Milestones
                milestones()
                
                // Weekly summary
                weeklySummary()
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color.black)
    }
    
    // MARK: - Recovery Timeline
    
    private func recoveryTimeline() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recovery Progress")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 0) {
                // Timeline items
                timelineItem(
                    week: "Week 1",
                    title: "Initial Recovery",
                    subtitle: "Focus on rest and healing",
                    completed: true,
                    current: false
                )
                
                timelineItem(
                    week: "Week 2",
                    title: "Building Strength",
                    subtitle: "Light movement introduced",
                    completed: true,
                    current: false
                )
                
                timelineItem(
                    week: "Week 3",
                    title: "Active Recovery",
                    subtitle: "Increasing daily activities",
                    completed: false,
                    current: true
                )
                
                timelineItem(
                    week: "Week 4-6",
                    title: "Continued Progress",
                    subtitle: "Building endurance",
                    completed: false,
                    current: false
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                    .stroke(
                        Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                        lineWidth: 1
                    )
            )
        }
    }
    
    private func timelineItem(
        week: String,
        title: String,
        subtitle: String,
        completed: Bool,
        current: Bool
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Indicator
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(
                            completed
                                ? Color(red: 0.24, green: 0.8, blue: 0.5)
                                : current
                                    ? Color(red: 0.53, green: 0.81, blue: 0.98)
                                    : Color(.sRGB, red: 0.25, green: 0.25, blue: 0.3)
                        )
                        .frame(width: 20, height: 20)
                    
                    if completed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                if week != "Week 4-6" {
                    Rectangle()
                        .fill(
                            completed
                                ? Color(red: 0.24, green: 0.8, blue: 0.5, opacity: 0.3)
                                : Color(.sRGB, red: 0.25, green: 0.25, blue: 0.3)
                        )
                        .frame(width: 2, height: 40)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(week)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(
                            Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55)
                        )
                    
                    if current {
                        Text("NOW")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(red: 0.53, green: 0.81, blue: 0.98))
                            )
                    }
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(
                        Color(.sRGB, red: 0.6, green: 0.6, blue: 0.65)
                    )
            }
            .padding(.bottom, week == "Week 4-6" ? 0 : 12)
            
            Spacer()
        }
    }
    
    // MARK: - Mood Trends
    
    private func moodTrends() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Mood Trends")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Last 14 days")
                    .font(.system(size: 12))
                    .foregroundColor(
                        Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55)
                    )
            }
            
            VStack(spacing: 16) {
                // Chart
                moodChart()
                
                // Average mood
                HStack(spacing: 16) {
                    moodStat(
                        label: "Average",
                        value: "Calm",
                        emoji: "😌"
                    )
                    
                    moodStat(
                        label: "Most Common",
                        value: "Hopeful",
                        emoji: "🌟"
                    )
                    
                    moodStat(
                        label: "Check-ins",
                        value: "23",
                        emoji: "✓"
                    )
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                    .stroke(
                        Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                        lineWidth: 1
                    )
            )
        }
    }
    
    private func moodChart() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Simple visual representation
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(mockMoodData, id: \.day) { data in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(moodColor(data.mood))
                            .frame(width: 18, height: CGFloat(data.intensity) * 60)
                        
                        Text(data.day)
                            .font(.system(size: 9))
                            .foregroundColor(
                                Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55)
                            )
                    }
                }
            }
            .frame(height: 100)
            
            Text("📈 Overall trend improving")
                .font(.system(size: 12))
                .foregroundColor(Color(red: 0.24, green: 0.8, blue: 0.5))
        }
    }
    
    private func moodStat(label: String, value: String, emoji: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 20))
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(
                    Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55)
                )
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Sleep Patterns
    
    private func sleepPatterns() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sleep Patterns")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 14) {
                // Average sleep
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(Color(red: 0.53, green: 0.81, blue: 0.98))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Average sleep")
                            .font(.system(size: 12))
                            .foregroundColor(
                                Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55)
                            )
                        
                        Text("6.2 hours/night")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Trend indicator
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10))
                        Text("+0.8h")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Color(red: 0.24, green: 0.8, blue: 0.5))
                }
                
                Divider()
                    .background(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25))
                
                // Quality
                HStack {
                    Image(systemName: "bed.double.fill")
                        .foregroundColor(Color(red: 0.65, green: 0.45, blue: 0.95))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sleep quality")
                            .font(.system(size: 12))
                            .foregroundColor(
                                Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55)
                            )
                        
                        Text("Improving")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("72%")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.24, green: 0.8, blue: 0.5))
                }
                
                Divider()
                    .background(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25))
                
                // Night wakings
                HStack {
                    Image(systemName: "bell.slash.fill")
                        .foregroundColor(Color(red: 0.94, green: 0.7, blue: 0.25))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Night wakings")
                            .font(.system(size: 12))
                            .foregroundColor(
                                Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55)
                            )
                        
                        Text("3.2 per night")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.right")
                            .font(.system(size: 10))
                        Text("-1.5")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Color(red: 0.24, green: 0.8, blue: 0.5))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                    .stroke(
                        Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                        lineWidth: 1
                    )
            )
        }
    }
    
    // MARK: - Milestones
    
    private func milestones() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Milestones")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 10) {
                milestoneCard(
                    icon: "figure.walk",
                    color: Color(red: 0.24, green: 0.8, blue: 0.5),
                    title: "First walk outside",
                    date: "5 days ago",
                    description: "15 minutes around the block"
                )
                
                milestoneCard(
                    icon: "heart.fill",
                    color: Color(red: 0.94, green: 0.25, blue: 0.37),
                    title: "Full night's sleep",
                    date: "1 week ago",
                    description: "7 hours uninterrupted"
                )
                
                milestoneCard(
                    icon: "sparkles",
                    color: Color(red: 0.53, green: 0.81, blue: 0.98),
                    title: "Feeling like yourself",
                    date: "2 weeks ago",
                    description: "First time since delivery"
                )
            }
        }
    }
    
    private func milestoneCard(
        icon: String,
        color: Color,
        title: String,
        date: String,
        description: String
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(
                        Color(.sRGB, red: 0.6, green: 0.6, blue: 0.65)
                    )
                
                Text(date)
                    .font(.system(size: 11))
                    .foregroundColor(
                        Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55)
                    )
            }
            
            Spacer()
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
    
    // MARK: - Weekly Summary
    
    private func weeklySummary() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 14) {
                summaryRow(
                    icon: "brain.fill",
                    color: Color(red: 0.65, green: 0.45, blue: 0.95),
                    label: "Mood check-ins",
                    value: "5"
                )
                
                summaryRow(
                    icon: "figure.walk",
                    color: Color(red: 0.94, green: 0.25, blue: 0.37),
                    label: "Exercise sessions",
                    value: "3"
                )
                
                summaryRow(
                    icon: "heart.fill",
                    color: Color(red: 0.2, green: 0.7, blue: 0.5),
                    label: "Baby check-ins",
                    value: "12"
                )
                
                summaryRow(
                    icon: "message.fill",
                    color: Color(red: 0.53, green: 0.81, blue: 0.98),
                    label: "Bloom conversations",
                    value: "8"
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                    .stroke(
                        Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                        lineWidth: 1
                    )
            )
            
            // Encouragement
            HStack(spacing: 10) {
                Image(systemName: "star.fill")
                    .foregroundColor(Color(red: 0.95, green: 0.78, blue: 0.25))
                
                Text("You're making great progress. Keep going!")
                    .font(.system(size: 13))
                    .foregroundColor(
                        Color(.sRGB, red: 0.7, green: 0.7, blue: 0.7)
                    )
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.2, green: 0.18, blue: 0.08))
                    .stroke(
                        Color(red: 0.95, green: 0.78, blue: 0.25, opacity: 0.3),
                        lineWidth: 1
                    )
            )
        }
    }
    
    private func summaryRow(
        icon: String,
        color: Color,
        label: String,
        value: String
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(
                    Color(.sRGB, red: 0.7, green: 0.7, blue: 0.75)
                )
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Helpers
    
    private func moodColor(_ mood: String) -> Color {
        switch mood {
        case "happy": return Color(red: 0.95, green: 0.78, blue: 0.25)
        case "calm": return Color(red: 0.53, green: 0.81, blue: 0.98)
        case "sad": return Color(red: 0.65, green: 0.45, blue: 0.95)
        case "anxious": return Color(red: 0.94, green: 0.5, blue: 0.37)
        default: return Color(.sRGB, red: 0.5, green: 0.5, blue: 0.5)
        }
    }
}

// MARK: - Mock Data

struct MoodDataPoint {
    let day: String
    let mood: String
    let intensity: Double
}

let mockMoodData: [MoodDataPoint] = [
    MoodDataPoint(day: "M", mood: "calm", intensity: 0.6),
    MoodDataPoint(day: "T", mood: "sad", intensity: 0.4),
    MoodDataPoint(day: "W", mood: "calm", intensity: 0.7),
    MoodDataPoint(day: "Th", mood: "happy", intensity: 0.8),
    MoodDataPoint(day: "F", mood: "calm", intensity: 0.75),
    MoodDataPoint(day: "S", mood: "happy", intensity: 0.85),
    MoodDataPoint(day: "Su", mood: "calm", intensity: 0.7),
]

#Preview {
    ScrollView {
        InsightsView()
    }
    .background(Color.black)
    .environmentObject(UserProfile.shared)
}
