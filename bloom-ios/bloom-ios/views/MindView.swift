//
//  MindView.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/1/26.
//

import SwiftUI
import Combine

struct MindView: View {
    @ObservedObject var service: BloomService
    @EnvironmentObject var profile: UserProfile

    @State private var selectedMood: Mood? = nil
    @State private var note = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Header
                header(
                    "How are you feeling?",
                    icon: "brain.fill",
                    color: Color(red: 0.65, green: 0.45, blue: 0.95)
                )

                // Mood grid
                moodGrid()

                // Note field
                noteField()

                // Submit
                submitButton(
                    disabled: selectedMood == nil || service.isLoading,
                    action: submitMood
                )

                // 🔹 AGENT STATUS (ADDED)
                if service.isLoading {
                    agentStatus()
                }

                // Response
                if let response = service.response,
                   service.routedPillar == .mind {
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
    }

    // MARK: - Agent Status (NEW)

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

    // MARK: - Mood Grid

    private func moodGrid() -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ],
            spacing: 10
        ) {
            ForEach(Mood.allCases, id: \.self) { mood in
                moodCell(mood)
            }
        }
    }

    private func moodCell(_ mood: Mood) -> some View {
        let selected = selectedMood == mood

        return Button {
            guard !service.isLoading else { return }
            selectedMood = mood
        } label: {
            VStack(spacing: 6) {
                Text(mood.emoji)
                    .font(.system(size: 28))

                Text(mood.rawValue.capitalized)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(
                        selected
                            ? .white
                            : Color(.sRGB, red: 0.6, green: 0.6, blue: 0.6)
                    )
            }
            .frame(maxWidth: .infinity)
            .frame(height: 88)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        selected
                            ? mood.color.opacity(0.2)
                            : Color(red: 0.08, green: 0.08, blue: 0.12)
                    )
                    .stroke(
                        selected
                            ? mood.color
                            : Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                        lineWidth: selected ? 1.8 : 1
                    )
            )
        }
        .disabled(service.isLoading)
    }

    // MARK: - Note

    private func noteField() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Anything on your mind? (optional)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(
                    Color(.sRGB, red: 0.5, green: 0.5, blue: 0.5)
                )

            TextField("Write a note...", text: $note, axis: .vertical)
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
        }
    }

    // MARK: - Actions

    private func submitMood() {
        guard let mood = selectedMood, !service.isLoading else { return }

        // Log mood locally
        profile.addMoodEntry(mood, note: note)

        service.request(
            message: note.isEmpty
                ? "I'm feeling \(mood.rawValue)"
                : note,
            pillar: .mind,
            context: profile.contextForServer()
        )

        // Reset form
        selectedMood = nil
        note = ""
    }
}

// MARK: - Shared layout helpers (unchanged)

func header(_ title: String, icon: String, color: Color) -> some View {
    HStack(spacing: 10) {
        Image(systemName: icon)
            .font(.system(size: 20))
            .foregroundColor(color)
        Text(title)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.white)
    }
}

func submitButton(disabled: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Text("Send to Bloom")
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(
                disabled
                    ? Color(.sRGB, red: 0.4, green: 0.4, blue: 0.4)
                    : .white
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        disabled
                            ? Color(red: 0.12, green: 0.12, blue: 0.16)
                            : Color(red: 0.53, green: 0.81, blue: 0.98)
                    )
                    .shadow(
                        color: disabled
                            ? Color.clear
                            : Color(
                                red: 0.53,
                                green: 0.81,
                                blue: 0.98,
                                opacity: 0.25
                            ),
                        radius: 10,
                        x: 0,
                        y: 4
                    )
            )
    }
    .disabled(disabled)
}

func loadingIndicator() -> some View {
    HStack(spacing: 10) {
        ProgressView()
            .progressViewStyle(
                CircularProgressViewStyle(
                    tint: Color(red: 0.53, green: 0.81, blue: 0.98)
                )
            )
        Text("Bloom is thinking...")
            .font(.system(size: 14))
            .foregroundColor(
                Color(.sRGB, red: 0.55, green: 0.55, blue: 0.55)
            )
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 12)
}

func errorBanner(_ message: String) -> some View {
    HStack(spacing: 10) {
        Image(systemName: "exclamationmark.circle.fill")
            .foregroundColor(Color(red: 0.94, green: 0.25, blue: 0.37))
        Text(message)
            .font(.system(size: 13))
            .foregroundColor(
                Color(.sRGB, red: 0.7, green: 0.7, blue: 0.7)
            )
    }
    .padding(14)
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(red: 0.2, green: 0.08, blue: 0.1))
            .stroke(
                Color(red: 0.94, green: 0.25, blue: 0.37, opacity: 0.3),
                lineWidth: 1
            )
    )
}

#Preview {
    ScrollView {
        MindView(service: BloomService())
    }
    .background(Color.black)
    .environmentObject(UserProfile.shared)
}
