//
//  SettingsView.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/8/26.
//


//
//  SettingsView.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/8/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var profile: UserProfile
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile section
                        profileSection()
                        
                        // Account section
                        accountSection()
                        
                        // About section
                        aboutSection()
                        
                        // Logout button
                        logoutButton()
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    // MARK: - Header
    
    private func header() -> some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 16))
                }
                .foregroundColor(Color(red: 0.53, green: 0.81, blue: 0.98))
            }
            
            Spacer()
            
            Text("Settings")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Invisible button for balance
            Button {} label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 16))
                }
            }
            .opacity(0)
            .disabled(true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.black)
    }
    
    // MARK: - Profile Section
    
    private func profileSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PROFILE")
                .font(.system(size: 11, weight: .bold))
                .kerning(1)
                .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
            
            VStack(spacing: 0) {
                // User info
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.53, green: 0.81, blue: 0.98, opacity: 0.15))
                            .frame(width: 56, height: 56)
                        
                        Text(profile.userName.prefix(1))
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(red: 0.53, green: 0.81, blue: 0.98))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.userName)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(profile.role == .mom ? "mom@bloom.com" : "dad@bloom.com")
                            .font(.system(size: 14))
                            .foregroundColor(Color(.sRGB, red: 0.6, green: 0.6, blue: 0.65))
                    }
                    
                    Spacer()
                }
                .padding(16)
                
                Divider()
                    .background(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25))
                
                // Role
                settingRow(
                    icon: "person.fill",
                    label: "Role",
                    value: profile.role == .mom ? "Mom" : "Partner"
                )
                
                Divider()
                    .background(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25))
                
                // Recovery stage
                settingRow(
                    icon: "heart.text.square.fill",
                    label: "Recovery Stage",
                    value: profile.recoveryStage.label
                )
                
                Divider()
                    .background(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25))
                
                // Baby name
                settingRow(
                    icon: "heart.fill",
                    label: "Baby",
                    value: profile.babyData.babyName
                )
            }
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
    
    // MARK: - Account Section
    
    private func accountSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ACCOUNT")
                .font(.system(size: 11, weight: .bold))
                .kerning(1)
                .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
            
            VStack(spacing: 0) {
                settingButton(
                    icon: "bell.fill",
                    label: "Notifications",
                    color: Color(red: 0.95, green: 0.78, blue: 0.25)
                )
                
                Divider()
                    .background(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25))
                
                settingButton(
                    icon: "lock.fill",
                    label: "Privacy",
                    color: Color(red: 0.65, green: 0.45, blue: 0.95)
                )
                
                Divider()
                    .background(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25))
                
                settingButton(
                    icon: "doc.text.fill",
                    label: "Terms & Conditions",
                    color: Color(red: 0.53, green: 0.81, blue: 0.98)
                )
            }
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
    
    // MARK: - About Section
    
    private func aboutSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ABOUT")
                .font(.system(size: 11, weight: .bold))
                .kerning(1)
                .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
            
            VStack(spacing: 0) {
                settingRow(
                    icon: "info.circle.fill",
                    label: "Version",
                    value: "1.0.0"
                )
                
                Divider()
                    .background(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25))
                
                settingButton(
                    icon: "questionmark.circle.fill",
                    label: "Help & Support",
                    color: Color(red: 0.2, green: 0.7, blue: 0.5)
                )
            }
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
    
    // MARK: - Logout Button
    
    private func logoutButton() -> some View {
        Button {
            profile.logout()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "arrow.right.square.fill")
                    .font(.system(size: 18))
                
                Text("Log Out")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(Color(red: 0.94, green: 0.25, blue: 0.37))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.2, green: 0.08, blue: 0.1))
                    .stroke(
                        Color(red: 0.94, green: 0.25, blue: 0.37, opacity: 0.3),
                        lineWidth: 1
                    )
            )
        }
    }
    
    // MARK: - Helper Views
    
    private func settingRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.53, green: 0.81, blue: 0.98))
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(Color(.sRGB, red: 0.6, green: 0.6, blue: 0.65))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
    
    private func settingButton(icon: String, label: String, color: Color) -> some View {
        Button {
            // Action placeholder
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(label)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(Color(.sRGB, red: 0.4, green: 0.4, blue: 0.45))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserProfile.shared)
}