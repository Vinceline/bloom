//
//  BreathingTimer.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/1/26.
//


import SwiftUI
import Combine

// MARK: - Timer State (ObservableObject owns all mutable state + the Timer)

private class TimerState: ObservableObject {
    let exercise: BreathingExercise
    let tickInterval = 0.05

    enum Phase: String {
        case inhale = "Breathe In"
        case hold   = "Hold"
        case exhale = "Breathe Out"
    }

    @Published var phase: Phase = .inhale
    @Published var roundsLeft: Int
    @Published var progress: Double = 0.0
    @Published var finished = false

    private var timer: Timer? = nil

    init(exercise: BreathingExercise) {
        self.exercise = exercise
        self.roundsLeft = exercise.rounds
    }

    // MARK: - Control

    func start() {
        stopTimer()
        progress = 0.0
        phase = .inhale
        finished = false
        roundsLeft = exercise.rounds
        let t = Timer(timeInterval: tickInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
        self.timer = t
        RunLoop.current.add(t, forMode: .common)
    }

    func stop() { stopTimer() }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Tick

    private func tick() {
        let duration = currentPhaseDuration
        guard duration > 0 else { return }

        progress += tickInterval / duration

        if progress >= 1.0 {
            progress = 0.0
            advancePhase()
        }
    }

    private func advancePhase() {
        switch phase {
        case .inhale: phase = .hold
        case .hold:   phase = .exhale
        case .exhale:
            roundsLeft -= 1
            if roundsLeft <= 0 {
                finished = true
                stopTimer()
            } else {
                phase = .inhale
            }
        }
    }

    // MARK: - Computed

    var currentPhaseDuration: Double {
        switch phase {
        case .inhale: return Double(exercise.inhaleSecs)
        case .hold:   return Double(exercise.holdSecs)
        case .exhale: return Double(exercise.exhaleSecs)
        }
    }

    var elapsed: Double { progress * currentPhaseDuration }

    var circleSize: CGFloat {
        let minSize: CGFloat = 100
        let maxSize: CGFloat = 180
        switch phase {
        case .inhale: return minSize + (maxSize - minSize) * progress
        case .exhale: return maxSize - (maxSize - minSize) * progress
        case .hold:   return maxSize
        }
    }

    var phaseColor: Color {
        switch phase {
        case .inhale: return Color(red: 0.53, green: 0.81, blue: 0.98)
        case .hold:   return Color(red: 0.67, green: 0.84, blue: 0.90)
        case .exhale: return Color(red: 0.53, green: 0.81, blue: 0.98)
        }
    }
}

// MARK: - BreathingTimer View

struct BreathingTimer: View {
    @StateObject private var state: TimerState

    init(exercise: BreathingExercise) {
        self._state = StateObject(wrappedValue: TimerState(exercise: exercise))
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(state.exercise.name)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            // Animated circle
            ZStack {
                Circle()
                    .fill(Color(red: 0.53, green: 0.81, blue: 0.98, opacity: 0.08))
                    .frame(width: 220, height: 220)

                Circle()
                    .stroke(Color(red: 0.53, green: 0.81, blue: 0.98, opacity: 0.15), lineWidth: 2)
                    .frame(width: 200, height: 200)

                Circle()
                    .fill(state.phaseColor.opacity(0.18))
                    .frame(width: state.circleSize, height: state.circleSize)
                    .animation(.easeInOut(duration: state.tickInterval), value: state.progress)

                Circle()
                    .stroke(state.phaseColor, lineWidth: 2.5)
                    .frame(width: state.circleSize, height: state.circleSize)
                    .animation(.easeInOut(duration: state.tickInterval), value: state.progress)

                VStack(spacing: 4) {
                    Text(state.phase.rawValue)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    Text("\(Int(state.currentPhaseDuration - state.elapsed))s")
                        .font(.system(size: 14))
                        .foregroundColor(Color(.sRGB, red: 0.55, green: 0.55, blue: 0.55))
                }
            }

            // Round counter
            Text(state.finished
                ? "Complete ✓"
                : "Round \(state.exercise.rounds - state.roundsLeft + 1) of \(state.exercise.rounds)")
                .font(.system(size: 13))
                .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.5))

            // Restart button (only shown when finished)
            if state.finished {
                Button(action: { state.start() }) {
                    Text("Do Again")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color(red: 0.53, green: 0.81, blue: 0.98)))
                }
            }
        }
        .padding(.vertical, 24)
        .onAppear  { state.start() }
        .onDisappear { state.stop() }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        BreathingTimer(exercise: BreathingExercise(
            name: "4-7-8 Breathing",
            inhaleSecs: 4,
            holdSecs: 7,
            exhaleSecs: 8,
            rounds: 3
        ))
    }
}
