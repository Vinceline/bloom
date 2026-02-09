//
//  AppointmentsView.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/8/26.
//


//
//  AppointmentsView.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/8/26.
//

import SwiftUI

struct AppointmentsView: View {
    @EnvironmentObject var profile: UserProfile
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab = 0 // 0 = Upcoming, 1 = Past
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header()
                
                // Tab selector
                tabSelector()
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        if selectedTab == 0 {
                            upcomingAppointments()
                        } else {
                            pastAppointments()
                        }
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
            
            Text("Appointments")
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
    
    // MARK: - Tab Selector
    
    private func tabSelector() -> some View {
        HStack(spacing: 12) {
            tabButton("Upcoming", index: 0)
            tabButton("Past", index: 1)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    private func tabButton(_ title: String, index: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        } label: {
            Text(title)
                .font(.system(size: 14, weight: selectedTab == index ? .semibold : .regular))
                .foregroundColor(
                    selectedTab == index
                        ? .white
                        : Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55)
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    selectedTab == index
                        ? RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 0.53, green: 0.81, blue: 0.98, opacity: 0.15))
                        : nil
                )
        }
    }
    
    // MARK: - Upcoming Appointments
    
    private func upcomingAppointments() -> some View {
        VStack(spacing: 16) {
            ForEach(profile.upcomingAppointments) { appointment in
                appointmentCard(appointment)
            }
            
            if profile.upcomingAppointments.isEmpty {
                emptyState(
                    icon: "calendar",
                    message: "No upcoming appointments"
                )
            }
        }
    }
    
    // MARK: - Past Appointments
    
    private func pastAppointments() -> some View {
        VStack(spacing: 16) {
            ForEach(profile.pastAppointments) { appointment in
                appointmentCard(appointment, isPast: true)
            }
            
            if profile.pastAppointments.isEmpty {
                emptyState(
                    icon: "checkmark.circle",
                    message: "No past appointments"
                )
            }
        }
    }
    
    // MARK: - Appointment Card
    
    private func appointmentCard(_ appointment: Appointment, isPast: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(appointment.type.color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: appointment.type.icon)
                        .font(.system(size: 20))
                        .foregroundColor(appointment.type.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(appointment.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(appointment.type.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
                }
                
                Spacer()
                
                if !isPast {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(daysUntil(appointment.date))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.53, green: 0.81, blue: 0.98))
                        
                        Text("days")
                            .font(.system(size: 10))
                            .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
                    }
                }
            }
            
            Divider()
                .background(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25))
            
            // Details
            VStack(spacing: 8) {
                detailRow(
                    icon: "calendar",
                    text: formatDate(appointment.date)
                )
                
                if let time = appointment.time {
                    detailRow(
                        icon: "clock",
                        text: time
                    )
                }
                
                if let location = appointment.location {
                    detailRow(
                        icon: "location.fill",
                        text: location
                    )
                }
                
                if let provider = appointment.provider {
                    detailRow(
                        icon: "person.fill",
                        text: provider
                    )
                }
            }
            
            // Notes (if past appointment)
            if isPast, let notes = appointment.notes {
                Divider()
                    .background(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.25))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Notes")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
                    
                    Text(notes)
                        .font(.system(size: 13))
                        .foregroundColor(Color(.sRGB, red: 0.7, green: 0.7, blue: 0.75))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                .stroke(
                    Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                    lineWidth: 1
                )
        )
    }
    
    private func detailRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
                .frame(width: 16)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(Color(.sRGB, red: 0.7, green: 0.7, blue: 0.75))
        }
    }
    
    // MARK: - Empty State
    
    private func emptyState(icon: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(Color(.sRGB, red: 0.3, green: 0.3, blue: 0.35))
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func daysUntil(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return "\(max(0, days))"
    }
}

#Preview {
    AppointmentsView()
        .environmentObject(UserProfile.shared)
}