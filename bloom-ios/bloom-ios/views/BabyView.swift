//
//  BabyView.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/1/26.
//


import SwiftUI

struct BabyView: View {
    @ObservedObject var service: BloomService
    @EnvironmentObject var profile: UserProfile

    @State private var showPhotoPicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var questionText = ""

    var babyName: String { profile.babyData.babyName }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                header("Hi, \(babyName)'s parent 👶", icon: "heart.fill", color: Color(red: 0.2, green: 0.7, blue: 0.5))

                // Cue reading — the main feature
                cueReadingSection()

                // Quick questions
                quickQuestions()

                // Free text question
                freeQuestionSection()

                // Loading
                if service.isLoading {
                    loadingIndicator()
                }

                // Response
                if let response = service.response, response.pillar == .baby {
                    ResponseCard(response: response)
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
            PhotoPicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .onChange(of: selectedImage) { newImage in
            if newImage != nil { submitCueReading() }
        }
    }

    // MARK: - Cue Reading

    private func cueReadingSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Read \(babyName)'s cues")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            Text("Upload a photo and Bloom will help you understand what \(babyName) needs")
                .font(.system(size: 12))
                .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))

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
                            .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.5))
                    }
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                        .stroke(Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24), lineWidth: 1)
                )
                .onTapGesture { showPhotoPicker = true }
            } else {
                Button { showPhotoPicker = true } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18))
                        Text("Upload a photo of \(babyName)")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.04, green: 0.15, blue: 0.1))
                            .stroke(Color(red: 0.2, green: 0.7, blue: 0.5, opacity: 0.3), lineWidth: 1)
                    )
                }
            }
        }
    }

    // MARK: - Quick Questions

    private func quickQuestions() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick questions")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            HStack(spacing: 10) {
                quickButton("🍼 Feeding", message: "I have a question about feeding \(babyName)")
                quickButton("😴 Sleep", message: "I have a question about \(babyName)'s sleep")
            }
        }
    }

    private func quickButton(_ label: String, message: String) -> some View {
        Button {
            service.request(
                message: message,
                pillar: .baby,
                context: profile.contextForServer()
            )
        } label: {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                        .stroke(Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24), lineWidth: 1)
                )
        }
    }

    // MARK: - Free Question

    private func freeQuestionSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ask anything about \(babyName)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            TextField("What's on your mind?", text: $questionText, axis: .vertical)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .lineLimit(1...3)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                        .stroke(Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24), lineWidth: 1)
                )
                .colorScheme(.dark)

            if !questionText.isEmpty {
                submitButton(disabled: false) {
                    service.request(
                        message: questionText,
                        pillar: .baby,
                        context: profile.contextForServer()
                    )
                    questionText = ""
                }
            }
        }
    }

    // MARK: - Actions

    private func submitCueReading() {
        guard let image = selectedImage else { return }
        service.request(
            message: "Please read \(babyName)'s cues in this photo",
            pillar: .baby,
            context: profile.contextForServer(),
            image: image
        )
    }
}

#Preview {
    ScrollView {
        BabyView(service: BloomService())
    }
    .background(Color.black)
    .environmentObject(UserProfile.shared)
}