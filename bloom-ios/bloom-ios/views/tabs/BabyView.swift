//
//  BabyView.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/8/26.
//
import SwiftUI
import Combine
struct BabyView: View {
    @ObservedObject var service: BloomService
    @EnvironmentObject var profile: UserProfile

    @State private var showPhotoPicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var questionText = ""

    var babyName: String { profile.babyData.babyName }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Header with back button
                headerWithBack(
                    "Hi, \(babyName)'s parent 👶",
                    icon: "heart.fill",
                    color: Color(red: 0.2, green: 0.7, blue: 0.5)
                )
                
                // Baby stats card
                babyStatsCard()
                
                // Growth tracking
                growthTracking()
                
                // Development milestones
                developmentMilestones()

                // Cue reading – the main feature
                cueReadingSection()

                // Quick questions
                quickQuestions()

                // Free text question
                freeQuestionSection()

                // Agent status
                if service.isLoading {
                    agentStatus()
                }

                // Response
                if let response = service.response,
                   service.routedPillar == .baby {
                    ResponseCard(
                        response: response
                    )
                }

                // Error
                if let error = service.error {
                    errorBanner(error)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color.black)
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker(
                selectedImage: $selectedImage,
                sourceType: .photoLibrary
            )
        }
        .onChange(of: selectedImage) { newImage in
            if newImage != nil {
                submitCueReading()
            }
        }
    }
    
    // MARK: - Baby Stats Card
    
    private func babyStatsCard() -> some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("\(babyName)'s Stats")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(profile.babyData.babyAgeWeeks) weeks old")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
            }
            .padding(.bottom, 16)
            
            // Stats grid
            HStack(spacing: 12) {
                statBox(
                    label: "Weight",
                    value: profile.babyData.currentWeight,
                    unit: "lbs",
                    icon: "scalemass.fill",
                    trend: "+1.2 lbs"
                )
                
                statBox(
                    label: "Length",
                    value: profile.babyData.currentLength,
                    unit: "in",
                    icon: "ruler.fill",
                    trend: "+1.5 in"
                )
            }
            
            Divider()
                .background(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25))
                .padding(.vertical, 14)
            
            // Feeding & sleep summary
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "drop.fill")
                        .foregroundColor(Color(red: 0.53, green: 0.81, blue: 0.98))
                        .frame(width: 20)
                    
                    Text("Feeds today")
                        .font(.system(size: 13))
                        .foregroundColor(Color(.sRGB, red: 0.6, green: 0.6, blue: 0.65))
                    
                    Spacer()
                    
                    Text("\(profile.babyData.feedsToday)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(Color(red: 0.65, green: 0.45, blue: 0.95))
                        .frame(width: 20)
                    
                    Text("Sleep today")
                        .font(.system(size: 13))
                        .foregroundColor(Color(.sRGB, red: 0.6, green: 0.6, blue: 0.65))
                    
                    Spacer()
                    
                    Text("\(profile.babyData.sleepHoursToday, specifier: "%.1f")h")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
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
    
    private func statBox(
        label: String,
        value: Double,
        unit: String,
        icon: String,
        trend: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.5))
                
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(value, specifier: "%.1f")")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text(unit)
                    .font(.system(size: 13))
                    .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
            }
            
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 9))
                Text(trend)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(Color(red: 0.24, green: 0.8, blue: 0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.04, green: 0.15, blue: 0.1))
        )
    }
    
    // MARK: - Growth Tracking
    
    private func growthTracking() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Growth Chart")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 14) {
                // Weight percentile
                percentileRow(
                    label: "Weight",
                    percentile: profile.babyData.weightPercentile,
                    color: Color(red: 0.53, green: 0.81, blue: 0.98)
                )
                
                // Length percentile
                percentileRow(
                    label: "Length",
                    percentile: profile.babyData.lengthPercentile,
                    color: Color(red: 0.2, green: 0.7, blue: 0.5)
                )
                
                Divider()
                    .background(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25))
                
                // Trend summary
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(Color(red: 0.24, green: 0.8, blue: 0.5))
                    
                    Text("\(babyName) is growing well and tracking on their own curve")
                        .font(.system(size: 13))
                        .foregroundColor(Color(.sRGB, red: 0.7, green: 0.7, blue: 0.75))
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
    
    private func percentileRow(label: String, percentile: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(Color(.sRGB, red: 0.6, green: 0.6, blue: 0.65))
                
                Spacer()
                
                Text("\(percentile)th percentile")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.sRGB, red: 0.15, green: 0.15, blue: 0.2))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(percentile) / 100, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
    
    // MARK: - Development Milestones
    
    private func developmentMilestones() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Development Milestones")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 10) {
                milestoneItem(
                    title: "Social smile",
                    status: "Achieved",
                    date: "1 week ago",
                    achieved: true
                )
                
                milestoneItem(
                    title: "Follows objects with eyes",
                    status: "In progress",
                    date: "Expected soon",
                    achieved: false
                )
                
                milestoneItem(
                    title: "Coos and babbles",
                    status: "Upcoming",
                    date: "4-6 weeks",
                    achieved: false
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
    
    private func milestoneItem(
        title: String,
        status: String,
        date: String,
        achieved: Bool
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        achieved
                            ? Color(red: 0.24, green: 0.8, blue: 0.5)
                            : Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25)
                    )
                    .frame(width: 32, height: 32)
                
                if achieved {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(date)
                    .font(.system(size: 12))
                    .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
            }
            
            Spacer()
            
            Text(status)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(
                    achieved
                        ? Color(red: 0.24, green: 0.8, blue: 0.5)
                        : Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55)
                )
        }
    }

    // MARK: - Agent Status

    private func agentStatus() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle(
                        tint: Color(red: 0.53, green: 0.81, blue: 0.98)
                    )
                )

            if let status = service.statusMessage {
                Text(status)
                    .font(.system(size: 12))
                    .foregroundColor(
                        Color(.sRGB, red: 0.6, green: 0.6, blue: 0.65)
                    )
            }

            if let pillar = service.routedPillar {
                Text("Routed to \(pillar.rawValue.capitalized) agent")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(
                        Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55)
                    )
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Cue Reading

    private func cueReadingSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Read \(babyName)'s cues")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            Text("Upload a photo and Bloom will help you understand what \(babyName) needs")
                .font(.system(size: 12))
                .foregroundColor(
                    Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55)
                )

            if let img = selectedImage {
                HStack(spacing: 12) {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 72, height: 72)
                        .clipped()
                        .cornerRadius(10)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Photo selected")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)

                        Text("Tap to change")
                            .font(.system(size: 11))
                            .foregroundColor(
                                Color(red: 0.2, green: 0.7, blue: 0.5)
                            )
                    }

                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                        .stroke(
                            Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                            lineWidth: 1
                        )
                )
                .onTapGesture {
                    guard !service.isLoading else { return }
                    showPhotoPicker = true
                }
            } else {
                Button {
                    guard !service.isLoading else { return }
                    showPhotoPicker = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18))
                        Text("Upload a photo of \(babyName)")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(
                        Color(red: 0.2, green: 0.7, blue: 0.5)
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.04, green: 0.15, blue: 0.1))
                            .stroke(
                                Color(
                                    red: 0.2,
                                    green: 0.7,
                                    blue: 0.5,
                                    opacity: 0.3
                                ),
                                lineWidth: 1
                            )
                    )
                }
                .disabled(service.isLoading)
            }
        }
    }

    // MARK: - Quick Questions

    private func quickQuestions() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick questions")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            HStack(spacing: 10) {
                quickButton(
                    "🍼 Feeding",
                    message: "I have a question about feeding \(babyName)"
                )
                quickButton(
                    "😴 Sleep",
                    message: "I have a question about \(babyName)'s sleep"
                )
            }
        }
    }

    private func quickButton(_ label: String, message: String) -> some View {
        Button {
            guard !service.isLoading else { return }
            service.request(
                message: message,
                pillar: .baby,
                context: profile.contextForServer()
            )
        } label: {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                        .stroke(
                            Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                            lineWidth: 1
                        )
                )
        }
        .disabled(service.isLoading)
    }

    // MARK: - Free Question

    private func freeQuestionSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ask anything about \(babyName)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            TextField(
                "What's on your mind?",
                text: $questionText,
                axis: .vertical
            )
            .font(.system(size: 14))
            .foregroundColor(.white)
            .lineLimit(1...3)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                    .stroke(
                        Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                        lineWidth: 1
                    )
            )
            .colorScheme(.dark)
            .disabled(service.isLoading)

            if !questionText.isEmpty {
                submitButton(disabled: service.isLoading) {
                    service.request(
                        message: questionText,
                        pillar: .baby,
                        context: profile.contextForServer()
                    )
                    questionText = ""
                }
            }
        }
    }

    // MARK: - Actions

    private func submitCueReading() {
        guard let image = selectedImage,
              !service.isLoading
        else { return }

        service.request(
            message: "Please read \(babyName)'s cues in this photo",
            pillar: .baby,
            context: profile.contextForServer(),
            image: image
        )
    }
}

#Preview {
    ScrollView {
        BabyView(service: BloomService())
    }
    .background(Color.black)
    .environmentObject(UserProfile.shared)
}
