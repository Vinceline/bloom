//
//  ContentView.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/1/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var profile: UserProfile
    @StateObject private var bloomService = BloomService()

    var body: some View {
        if !profile.onboardingComplete {
            OnboardingView()
        } else {
            TabView {
                MindView(service: bloomService)
                    .tabItem {
                        Label("Mind", systemImage: "brain.fill")
                    }

                BodyView(service: bloomService)
                    .tabItem {
                        Label("Body", systemImage: "figure.standing")
                    }

                BabyView(service: bloomService)
                    .tabItem {
                        Label("Baby", systemImage: "heart.fill")
                    }

                PartnerView(service: bloomService)
                    .tabItem {
                        Label("Partner", systemImage: "hands.sparkles.fill")
                    }
            }
            .accentColor(Color(red: 0.53, green: 0.81, blue: 0.98))
            .colorScheme(.dark)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserProfile.shared)
}
