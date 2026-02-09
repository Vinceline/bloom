//
//  PartnerView.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/1/26.
//
import SwiftUI

struct PartnerView: View {
    @ObservedObject var service: BloomService
    @EnvironmentObject var profile: UserProfile

    @State private var inputText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Header
                header(
                    "You matter too",
                    icon: "hands.sparkles.fill",
                    color: Color(red: 0.22, green: 0.72, blue: 0.96)
                )

                // Context snapshot — what's actually happening right now
                contextSnapshot()

                // Hero: "How can I help?"
                helpNowButton()

                // Free text input
                freeInputSection()

                // Quick questions
                quickQuestions()

                // 🔹 AGENT STATUS (ADDED)
                if service.isLoading {
                    agentStatus()
                }

                // Response
                if let response = service.response, service.routedPillar == .partner {
                    ResponseCard(response: response)

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
    }

    // MARK: - Agent Status (NEW)

    private func agentStatus() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ProgressView()

            if let status = service.statusMessage {
                Text(status)
                    .font(.system(size: 12))
                    .foregroundColor(Color(.sRGB, red: 0.6, green: 0.6, blue: 0.65))
            }

            if let pillar = service.routedPillar {
                Text("Routed to \(pillar.rawValue.capitalized) agent")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Context Snapshot

    private func contextSnapshot() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("RIGHT NOW")
                .font(.system(size: 10, weight: .bold))
                .kerning(1)
                .foregroundColor(Color(.sRGB, red: 0.45, green: 0.45, blue: 0.5))
                .padding(.bottom, 12)

            contextRow(
                icon: "heart.fill",
                iconColor: Color(red: 0.95, green: 0.7, blue: 0.5),
                label: "Mom's mood",
                value: lastMoodLabel
            )

            Divider()
                .background(Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24))
                .padding(.vertical, 10)

            contextRow(
                icon: "moon.stars",
                iconColor: Color(red: 0.4, green: 0.7, blue: 0.9),
                label: profile.babyData.babyName.isEmpty
                    ? "Baby"
                    : profile.babyData.babyName,
                value: babyStatusLabel
            )

            Divider()
                .background(Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24))
                .padding(.vertical, 10)

            contextRow(
                icon: "figure.walk",
                iconColor: Color(red: 0.5, green: 0.75, blue: 0.6),
                label: "Recovery",
                value: "\(profile.recoveryStage.label) · \(profile.deliveryType == .cesarean ? "C-section" : "Vaginal")"
            )
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

    private func contextRow(
        icon: String,
        iconColor: Color,
        label: String,
        value: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(iconColor)
                .frame(width: 20)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color(.sRGB, red: 0.55, green: 0.55, blue: 0.6))

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
    }

    // MARK: - Hero Button

    private func helpNowButton() -> some View {
        Button {
            guard !service.isLoading else { return }
            service.request(
                message: "How can I help right now? Give me something specific I can do.",
                pillar: .partner,
                context: profile.contextForServer()
            )
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.22, green: 0.72, blue: 0.96, opacity: 0.15))
                        .frame(width: 60, height: 60)

                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Color(red: 0.22, green: 0.72, blue: 0.96))
                }

                Text("How can I help right now?")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)

                Text("Bloom looks at what's happening and gives you something specific")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)

                Text("Tap for a suggestion →")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.22, green: 0.72, blue: 0.96))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.06, green: 0.12, blue: 0.18))
                    .stroke(
                        Color(red: 0.22, green: 0.72, blue: 0.96, opacity: 0.25),
                        lineWidth: 1
                    )
            )
        }
        .disabled(service.isLoading)
    }

    // MARK: - Free Input

    private func freeInputSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Or ask your own question")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            HStack(spacing: 10) {
                TextField(
                    "What's on your mind?",
                    text: $inputText,
                    axis: .vertical
                )
                .font(.system(size: 14))
                .foregroundColor(.white)
                .lineLimit(1...2)
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
                .onSubmit { sendMessage() }

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 34))
                        .foregroundColor(
                            inputText.isEmpty
                                ? Color(.sRGB, red: 0.25, green: 0.25, blue: 0.3)
                                : Color(red: 0.22, green: 0.72, blue: 0.96)
                        )
                }
                .disabled(inputText.isEmpty || service.isLoading)
            }
        }
    }

    // MARK: - Quick Questions

    private func quickQuestions() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Common questions")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            let questions = [
                "How can I support her emotionally right now?",
                "What should I know about newborn care?",
                "How do I know if she needs help?"
            ]

            ForEach(questions, id: \.self) { q in
                Button {
                    guard !service.isLoading else { return }
                    service.request(
                        message: q,
                        pillar: .partner,
                        context: profile.contextForServer()
                    )
                } label: {
                    HStack {
                        Text(q)
                            .font(.system(size: 14))
                            .foregroundColor(
                                Color(.sRGB, red: 0.72, green: 0.72, blue: 0.75)
                            )
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(
                                Color(.sRGB, red: 0.4, green: 0.4, blue: 0.45)
                            )
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
                .disabled(service.isLoading)
            }
        }
    }

    // MARK: - Helpers

    private func sendMessage() {
        guard !inputText.isEmpty, !service.isLoading else { return }
        service.request(
            message: inputText,
            pillar: .partner,
            context: profile.contextForServer()
        )
        inputText = ""
    }

    private var lastMoodLabel: String {
        guard let last = profile.moodHistory.last else {
            return "No check-in yet"
        }
        return "\(last.mood.emoji) \(last.mood.rawValue.capitalized)"
    }

    private var babyStatusLabel: String {
        let feed = profile.babyData.lastFeedHoursAgo
        let status = profile.babyData.currentStatus
        if status == "sleeping" { return "Sleeping" }
        if feed == 0 { return "Just fed" }
        if feed < 1 { return "Fed \(Int(feed * 60))min ago" }
        return "Fed \(Int(feed))h ago"
    }
}

#Preview {
    ScrollView {
        PartnerView(service: BloomService())
    }
    .background(Color.black)
    .environmentObject(UserProfile.shared)
}
