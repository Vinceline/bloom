//
//  LoginView.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/8/26.
//


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
    @State private var isSignUp = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 60)
                    
                    // Logo
                    VStack(spacing: 12) {
                        Image("bloom-logo-alpha")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                        
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
                            
                            TextField("your@email.com", text: $email)
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
                            
                            SecureField("••••••••", text: $password)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .textContentType(isSignUp ? .newPassword : .password)
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
                        
                        // Sign In / Sign Up button
                        Button(action: handleAuth) {
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .font(.system(size: 16, weight: .semibold))
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
                        .disabled(email.isEmpty || password.isEmpty)
                        .opacity(email.isEmpty || password.isEmpty ? 0.5 : 1)
                    }
                    .padding(.horizontal, 20)
                    
                    // Toggle between sign in and sign up
                    Button {
                        withAnimation {
                            isSignUp.toggle()
                            showError = false
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                .font(.system(size: 14))
                                .foregroundColor(Color(.sRGB, red: 0.6, green: 0.6, blue: 0.65))
                            Text(isSignUp ? "Sign In" : "Sign Up")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.53, green: 0.81, blue: 0.98))
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private func handleAuth() {
        // Fake authentication - any email/password combo works
        guard !email.isEmpty, !password.isEmpty else {
            showError = true
            errorMessage = "Please enter both email and password"
            return
        }
        
        // Simple email validation
        guard email.contains("@") && email.contains(".") else {
            showError = true
            errorMessage = "Please enter a valid email address"
            return
        }
        
        // Password length check
        guard password.count >= 6 else {
            showError = true
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        // Success - proceed to onboarding
        withAnimation {
            profile.isLoggedIn = true
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(UserProfile.shared)
}
