//
//  ResponseCard.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/1/26.
//
import SwiftUI

struct ResponseCard: View {
    @State private var showBreathing = false
    let response: BloomResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ─────────────────────────
            HStack(spacing: 10) {
                PillarBadge(pillar: response.pillar)

                Text(response.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 12)

            Divider()
                .background(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25))
                .padding(.bottom, 14)

            // ── Main content ───────────────────
            Text(response.content)
                .font(.system(size: 14))
                .foregroundColor(Color(.sRGB, red: 0.78, green: 0.78, blue: 0.78))
                .lineSpacing(6)

            // ── Mind: breathing exercise ───────
            if let breathing = response.breathing {
                Spacer().frame(height: 16)
                breathingButton(breathing)
            }

            // ── Mind: mood insight ─────────────
            if let insight = response.moodInsight {
                Spacer().frame(height: 14)
                insightBanner(insight)
            }

            // ── Body: exercise steps ───────────
            if let steps = response.exerciseSteps, !steps.isEmpty {
                Spacer().frame(height: 16)
                exerciseSteps(steps)
            }

            // ── Baby: cue readout ──────────────
            if let readout = response.babyReadout {
                Spacer().frame(height: 16)
                babyReadoutCard(readout)
            }

            // ── Partner: actions ───────────────
            if let actions = response.partnerActions, !actions.isEmpty {
                Spacer().frame(height: 16)
                partnerActions(actions)
            }

            // ── Universal suggestion ───────────
            if let suggestion = response.suggestion {
                Spacer().frame(height: 16)
                suggestionBanner(suggestion)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                .stroke(Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24), lineWidth: 1)
        )
        .sheet(isPresented: $showBreathing) {
            breathingSheet
        }
    }

    // MARK: - Subviews

    private func breathingButton(_ exercise: BreathingExercise) -> some View {
        Button { showBreathing = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "lungs.fill")
                Text("Start \(exercise.name)")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
            }
            .foregroundColor(.white)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.53, green: 0.81, blue: 0.98, opacity: 0.15))
                    .stroke(Color(red: 0.53, green: 0.81, blue: 0.98, opacity: 0.3), lineWidth: 1)
            )
        }
    }

    private func insightBanner(_ insight: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .foregroundColor(Color(red: 0.53, green: 0.81, blue: 0.98))
            Text(insight)
                .font(.system(size: 13))
                .foregroundColor(Color(.sRGB, red: 0.65, green: 0.65, blue: 0.65))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.53, green: 0.81, blue: 0.98, opacity: 0.08))
        )
    }

    private func exerciseSteps(_ steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("EXERCISES")

            ForEach(steps.indices, id: \.self) { i in
                HStack(alignment: .top, spacing: 12) {
                    stepNumber(i + 1)
                    Text(steps[i])
                        .font(.system(size: 13))
                        .foregroundColor(Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75))
                }
            }
        }
    }

    private func babyReadoutCard(_ readout: BabyReadout) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Baby is likely:")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)

                Text(readout.likelyState.capitalized)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(stateColor(readout.likelyState))

                Spacer()

                Text(readout.confidence.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(confidenceColor(readout.confidence))
                    )
            }

            Text(readout.guidance)
                .font(.system(size: 13))
                .foregroundColor(Color(.sRGB, red: 0.7, green: 0.7, blue: 0.7))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.0, green: 0.22, blue: 0.14))
                .stroke(Color(red: 0.0, green: 0.45, blue: 0.3, opacity: 0.3), lineWidth: 1)
        )
    }

    private func partnerActions(_ actions: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("WHAT YOU CAN DO")

            ForEach(actions, id: \.self) { action in
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(red: 0.22, green: 0.72, blue: 0.96))
                    Text(action)
                        .font(.system(size: 13))
                        .foregroundColor(Color(.sRGB, red: 0.78, green: 0.78, blue: 0.78))
                }
            }
        }
    }

    private func suggestionBanner(_ suggestion: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(Color(red: 0.95, green: 0.78, blue: 0.25))
            Text(suggestion)
                .font(.system(size: 13))
                .foregroundColor(Color(.sRGB, red: 0.7, green: 0.7, blue: 0.7))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.2, green: 0.18, blue: 0.08))
        )
    }

    private var breathingSheet: some View {
        Group {
            if let b = response.breathing {
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack {
                        HStack {
                            Spacer()
                            Button("Done") { showBreathing = false }
                                .foregroundColor(Color(red: 0.53, green: 0.81, blue: 0.98))
                                .padding()
                        }
                        Spacer()
                        BreathingTimer(exercise: b)
                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: - Small helpers

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .kerning(1)
            .foregroundColor(Color(.sRGB, red: 0.45, green: 0.45, blue: 0.5))
    }

    private func stepNumber(_ n: Int) -> some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.24, green: 0.55, blue: 0.36))
                .frame(width: 24, height: 24)
            Text("\(n)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
        }
    }

    private func stateColor(_ state: String) -> Color {
        switch state.lowercased() {
        case "hungry": return .orange
        case "tired": return Color(red: 0.53, green: 0.81, blue: 0.98)
        case "comfortable": return .green
        case "fussy": return .red
        default: return .gray
        }
    }

    private func confidenceColor(_ level: String) -> Color {
        switch level.lowercased() {
        case "high": return .green
        case "medium": return .yellow
        default: return .gray
        }
    }
}


// MARK: - Pillar Badge

struct PillarBadge: View {
    let pillar: BloomPillar

    var body: some View {
        Text(pillar.rawValue.capitalized)
            .font(.system(size: 10, weight: .bold))
            .kerning(0.5)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 12).fill(pillarColor))
    }

    private var pillarColor: Color {
        switch pillar {
        case .mind:    return Color(red: 0.65, green: 0.45, blue: 0.95)
        case .body:    return Color(red: 0.94, green: 0.25, blue: 0.37)
        case .baby:    return Color(red: 0.2,  green: 0.7,  blue: 0.5)
        case .partner: return Color(red: 0.22, green: 0.72, blue: 0.96)
        }
    }
}
