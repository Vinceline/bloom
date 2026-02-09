//
//  BodyView.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/1/26.
//
import SwiftUI

struct BodyView: View {
    @ObservedObject var service: BloomService
    @EnvironmentObject var profile: UserProfile

    @State private var showPhotoPicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var symptomText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Header
                header(
                    "Your Recovery",
                    icon: "figure.walk",
                    color: Color(red: 0.94, green: 0.25, blue: 0.37)
                )

                // Recovery stage card
                recoveryStageCard()

                // Photo upload section
                photoSection()

                // Symptom check
                symptomSection()

                // Exercise button
                exerciseButton()

                // 🔹 AGENT STATUS (ADDED)
                if service.isLoading {
                    agentStatus()
                }

                // Response
                if let response = service.response,
                   service.routedPillar == .body {
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
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker(
                selectedImage: $selectedImage,
                sourceType: .photoLibrary
            )
        }
        .onChange(of: selectedImage) { newImage in
            if newImage != nil {
                submitPhoto()
            }
        }
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

    // MARK: - Recovery Stage Card

    private func recoveryStageCard() -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("RECOVERY STAGE")
                    .font(.system(size: 10, weight: .bold))
                    .kerning(1)
                    .foregroundColor(Color(.sRGB, red: 0.45, green: 0.45, blue: 0.5))

                Text(profile.recoveryStage.label)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Text(
                    profile.deliveryType == .cesarean
                        ? "C-section recovery"
                        : "Vaginal recovery"
                )
                .font(.system(size: 12))
                .foregroundColor(
                    Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55)
                )
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(
                    Color(.sRGB, red: 0.4, green: 0.4, blue: 0.45)
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

    // MARK: - Photo Section

    private func photoSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Check your healing")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            Text("Upload a photo and Bloom will help you understand your progress")
                .font(.system(size: 12))
                .foregroundColor(
                    Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55)
                )

            if let img = selectedImage {
                HStack(spacing: 12) {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 72, height: 72)
                        .clipped()
                        .cornerRadius(10)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Photo selected")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)

                        Text("Tap to change")
                            .font(.system(size: 11))
                            .foregroundColor(
                                Color(red: 0.53, green: 0.81, blue: 0.98)
                            )
                    }

                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                        .stroke(
                            Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                            lineWidth: 1
                        )
                )
                .onTapGesture {
                    guard !service.isLoading else { return }
                    showPhotoPicker = true
                }
            } else {
                Button {
                    guard !service.isLoading else { return }
                    showPhotoPicker = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18))
                        Text("Upload healing photo")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(
                        Color(red: 0.94, green: 0.25, blue: 0.37)
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.18, green: 0.06, blue: 0.08))
                            .stroke(
                                Color(
                                    red: 0.94,
                                    green: 0.25,
                                    blue: 0.37,
                                    opacity: 0.3
                                ),
                                lineWidth: 1
                            )
                    )
                }
                .disabled(service.isLoading)
            }
        }
    }

    // MARK: - Symptom Section

    private func symptomSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Symptom check")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            TextField(
                "Describe what you're feeling...",
                text: $symptomText,
                axis: .vertical
            )
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

            if !symptomText.isEmpty {
                submitButton(disabled: service.isLoading) {
                    service.request(
                        message: symptomText,
                        pillar: .body,
                        context: profile.contextForServer()
                    )
                    symptomText = ""
                }
            }
        }
    }

    // MARK: - Exercise Button

    private func exerciseButton() -> some View {
        Button {
            guard !service.isLoading else { return }
            service.request(
                message: "Give me exercises for my recovery stage",
                pillar: .body,
                context: profile.contextForServer()
            )
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "figure.walk.circle")
                    .font(.system(size: 18))

                Text("Get exercise recommendations")
                    .font(.system(size: 14, weight: .medium))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
            }
            .foregroundColor(.white)
            .padding(16)
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

    // MARK: - Actions

    private func submitPhoto() {
        guard let image = selectedImage,
              !service.isLoading
        else { return }

        service.request(
            message: "Please analyze my healing progress",
            pillar: .body,
            context: profile.contextForServer(),
            image: image
        )
    }
}

#Preview {
    ScrollView {
        BodyView(service: BloomService())
    }
    .background(Color.black)
    .environmentObject(UserProfile.shared)
}
