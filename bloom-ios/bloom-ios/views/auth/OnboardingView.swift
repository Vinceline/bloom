//
//  OnboardingView.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/1/26.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var profile: UserProfile
    @State private var step = 0          // 0 = role, 1 = delivery (mom only), 2 = baby name
    @State private var babyName = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo + brand
                VStack(spacing: 12) {
                    Image("bloom-logo-alpha")
                                           .resizable()
                                           .aspectRatio(contentMode: .fit)
                                           .frame(width: 200, height: 200)
                                           .foregroundColor(Color(red: 0.53, green: 0.81, blue: 0.98))

                    Text("Bloom")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .italic()
                        .foregroundColor(.white)


                    Text("Postpartum support for everyone")
                        .font(.system(size: 15))
                        .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.5))
                }
                .padding(.bottom, 48)

                // Step content
                switch step {
                case 0: roleStep()
                case 1: deliveryStep()
                default: babyNameStep()
                }

                Spacer()
            }
        }
    }

    // MARK: - Step 0: Role

    private func roleStep() -> some View {
        VStack(spacing: 16) {
            Text("Who are you?")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.bottom, 8)

            roleButton(.mom, icon: "heart.fill", label: "I'm the mother")
            roleButton(.partner, icon: "hands.sparkles.fill", label: "I'm the partner")
        }
    }

    private func roleButton(_ role: UserRole, icon: String, label: String) -> some View {
        Button {
            profile.role = role
            step = (role == .mom) ? 1 : 2   // partners skip delivery type
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(role == .mom
                        ? Color(red: 0.94, green: 0.25, blue: 0.37)
                        : Color(red: 0.22, green: 0.72, blue: 0.96))
                    .frame(width: 28)
                Text(label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color(.sRGB, red: 0.4, green: 0.4, blue: 0.45))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.14))
                    .stroke(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.26), lineWidth: 1)
            )
        }
        .frame(maxWidth: 320)
    }

    // MARK: - Step 1: Delivery Type (mom only)

    private func deliveryStep() -> some View {
        VStack(spacing: 16) {
            Text("How was your delivery?")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.bottom, 8)

            deliveryButton(.vaginal, label: "Vaginal delivery")
            deliveryButton(.cesarean, label: "C-section")
        }
    }

    private func deliveryButton(_ type: DeliveryType, label: String) -> some View {
        Button {
            profile.deliveryType = type
            step = 2
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.24, green: 0.8, blue: 0.5))
                    .frame(width: 28)
                Text(label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color(.sRGB, red: 0.4, green: 0.4, blue: 0.45))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.14))
                    .stroke(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.26), lineWidth: 1)
            )
        }
        .frame(maxWidth: 320)
    }

    // MARK: - Step 2: Baby Name

    private func babyNameStep() -> some View {
        VStack(spacing: 20) {
            Text("What's your baby's name?")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            TextField("Baby's name", text: $babyName)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(red: 0.1, green: 0.1, blue: 0.14))
                        .stroke(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.26), lineWidth: 1)
                )
                .colorScheme(.dark)
                .frame(maxWidth: 320)

            // Continue button
            Button {
                profile.babyData.babyName = babyName.isEmpty ? "Baby Leo" : babyName
                profile.onboardingComplete = true
                profile.deliveryDate = Date()
                profile.save()
            } label: {
                Text("Let's go")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(red: 0.53, green: 0.81, blue: 0.98))
                            .shadow(color: Color(red: 0.53, green: 0.81, blue: 0.98, opacity: 0.3), radius: 12, x: 0, y: 4)
                    )
            }
            .frame(maxWidth: 320)
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(UserProfile.shared)
}
