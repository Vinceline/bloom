//
//  ViewHelpers.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/8/26.
//



import SwiftUI

// MARK: - Header with Back Button

func headerWithBack(_ title: String, icon: String, color: Color) -> some View {
    HStack(spacing: 10) {
        Image(systemName: icon)
            .font(.system(size: 20))
            .foregroundColor(color)
        Text(title)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.white)
    }
}

// MARK: - Simple Header (from MindView.swift)

func header(_ title: String, icon: String, color: Color) -> some View {
    HStack(spacing: 10) {
        Image(systemName: icon)
            .font(.system(size: 20))
            .foregroundColor(color)
        Text(title)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.white)
    }
}

func submitButton(disabled: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Text("Send to Bloom")
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(
                disabled
                    ? Color(.sRGB, red: 0.4, green: 0.4, blue: 0.4)
                    : .white
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        disabled
                            ? Color(red: 0.12, green: 0.12, blue: 0.16)
                            : Color(red: 0.53, green: 0.81, blue: 0.98)
                    )
                    .shadow(
                        color: disabled
                            ? Color.clear
                            : Color(
                                red: 0.53,
                                green: 0.81,
                                blue: 0.98,
                                opacity: 0.25
                            ),
                        radius: 10,
                        x: 0,
                        y: 4
                    )
            )
    }
    .disabled(disabled)
}

func loadingIndicator() -> some View {
    HStack(spacing: 10) {
        ProgressView()
            .progressViewStyle(
                CircularProgressViewStyle(
                    tint: Color(red: 0.53, green: 0.81, blue: 0.98)
                )
            )
        Text("Bloom is thinking...")
            .font(.system(size: 14))
            .foregroundColor(
                Color(.sRGB, red: 0.55, green: 0.55, blue: 0.55)
            )
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 12)
}

func errorBanner(_ message: String) -> some View {
    HStack(spacing: 10) {
        Image(systemName: "exclamationmark.circle.fill")
            .foregroundColor(Color(red: 0.94, green: 0.25, blue: 0.37))
        Text(message)
            .font(.system(size: 13))
            .foregroundColor(
                Color(.sRGB, red: 0.7, green: 0.7, blue: 0.7)
            )
    }
    .padding(14)
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(red: 0.2, green: 0.08, blue: 0.1))
            .stroke(
                Color(red: 0.94, green: 0.25, blue: 0.37, opacity: 0.3),
                lineWidth: 1
            )
    )
}
