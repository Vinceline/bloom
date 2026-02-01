//
//  bloom_iosApp.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/1/26.
//

import SwiftUI

@main
struct bloom_iosApp: App {
    @StateObject private var profile = UserProfile.shared

       var body: some Scene {
           WindowGroup {
               ContentView()
                   .environmentObject(profile)
           }
       }
}
