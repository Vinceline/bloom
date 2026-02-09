//
//  LoginView.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/8/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var profile: UserProfile
    
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 60)
                    
                    // Logo
                    VStack(spacing: 12) {
                        Image(systemName: "leaf.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color(red: 0.53, green: 0.81, blue: 0.98))
                        
                        Text("Bloom")
                            .font(.system(size: 36, weight: .bold, design: .serif))
                            .italic()
                            .foregroundColor(.white)
                        
                        Text("Your postpartum companion")
                            .font(.system(size: 15))
                            .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.5))
                    }
                    .padding(.bottom, 24)
                    
                    // Form
                    VStack(spacing: 16) {
                        // Email
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(.sRGB, red: 0.6, green: 0.6, blue: 0.65))
                            
                            TextField("mom@bloom.com or dad@bloom.com", text: $email)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
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
                        }
                        
                        // Password
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(.sRGB, red: 0.6, green: 0.6, blue: 0.65))
                            
                            SecureField("password", text: $password)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .textContentType(.password)
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
                        }
                        
                        // Error message
                        if showError {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(Color(red: 0.94, green: 0.25, blue: 0.37))
                                Text(errorMessage)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(.sRGB, red: 0.7, green: 0.7, blue: 0.7))
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 0.2, green: 0.08, blue: 0.1))
                            )
                        }
                        
                        // Sign In button
                        Button(action: handleAuth) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Sign In")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(red: 0.53, green: 0.81, blue: 0.98))
                                    .shadow(
                                        color: Color(red: 0.53, green: 0.81, blue: 0.98, opacity: 0.3),
                                        radius: 12,
                                        x: 0,
                                        y: 4
                                    )
                            )
                        }
                        .disabled(email.isEmpty || password.isEmpty || isLoading)
                        .opacity(email.isEmpty || password.isEmpty || isLoading ? 0.5 : 1)
                    }
                    .padding(.horizontal, 20)
                    
                    // Demo credentials hint
                    VStack(spacing: 12) {
                        Text("Demo Credentials")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
                        
                        VStack(spacing: 8) {
                            credentialHint(role: "Mom", email: "mom@bloom.com")
                            credentialHint(role: "Dad", email: "dad@bloom.com")
                            
                            Text("Password: password")
                                .font(.system(size: 11))
                                .foregroundColor(Color(.sRGB, red: 0.45, green: 0.45, blue: 0.5))
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private func credentialHint(role: String, email: String) -> some View {
        HStack(spacing: 6) {
            Text(role + ":")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
            
            Button {
                self.email = email
                self.password = "password"
            } label: {
                Text(email)
                    .font(.system(size: 11))
                    .foregroundColor(Color(red: 0.53, green: 0.81, blue: 0.98))
            }
        }
    }
    
    private func handleAuth() {
        showError = false
        
        // Hardcoded authentication
        let emailLower = email.lowercased().trimmingCharacters(in: .whitespaces)
        
        guard password == "password" else {
            showError = true
            errorMessage = "Invalid password"
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            
            switch emailLower {
            case "mom@bloom.com":
                profile.userName = "Sarah"
                profile.role = .mom
                profile.isLoggedIn = true
                profile.onboardingComplete = true
                profile.loadMomDemoData()
                
            case "dad@bloom.com":
                profile.userName = "Michael"
                profile.role = .partner
                profile.isLoggedIn = true
                profile.onboardingComplete = true
                profile.loadPartnerDemoData()
                
            default:
                showError = true
                errorMessage = "Invalid email. Use mom@bloom.com or dad@bloom.com"
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(UserProfile.shared)
}
