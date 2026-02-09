import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var profile: UserProfile
    @StateObject private var service = BloomService()
    @State private var showSettings = false
    
    @State private var selectedTab = 0
    @State private var showAppointments = false
    
    var body: some View {
        Group {
            if !profile.isLoggedIn {
                LoginView()
            } else if !profile.onboardingComplete {
                OnboardingView()
            } else {
                mainInterface
            }
        }
    }
    
    private var mainInterface: some View {
        ZStack(alignment: .bottom) {
            // Content
            TabView(selection: $selectedTab) {
                if profile.role == .mom {
                    // Mom's tabs
                    MindView(service: service)
                        .padding(.bottom, 100) // Add padding for tab bar
                        .tag(0)
                    
                    BodyView(service: service)
                        .padding(.bottom, 100)
                        .tag(1)
                    
                    BabyView(service: service)
                        .padding(.bottom, 100)
                        .tag(2)
                    
                    InsightsView()
                        .padding(.bottom, 100)
                        .tag(3)
                } else {
                    // Partner's tabs
                    MomView()
                        .padding(.bottom, 100)
                        .tag(0)
                    
                    BabyView(service: service)
                        .padding(.bottom, 100)
                        .tag(1)
                    
                    PartnerView(service: service)
                        .padding(.bottom, 100)
                        .tag(2)
                    
                    InsightsView()
                        .padding(.bottom, 100)
                        .tag(3)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Top right buttons (Appointments & Settings)
            VStack {
                HStack {
                    Spacer()
                    
                    HStack(spacing: 12) {
                        // Appointments button
                        Button {
                            showAppointments = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 14))
                                Text("Visits")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                                    .stroke(
                                        Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                                        lineWidth: 1
                                    )
                            )
                        }
                        
                        // Settings button
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                                        .stroke(
                                            Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                                            lineWidth: 1
                                        )
                                )
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 16)
                }
                
                Spacer()
            }
            
            // Custom tab bar
            customTabBar
        }
        .background(Color.black.ignoresSafeArea())
        .sheet(isPresented: $showAppointments) {
            AppointmentsView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            if profile.role == .mom {
                tabButton(
                    icon: "brain.fill",
                    label: "Mind",
                    color: Color(red: 0.65, green: 0.45, blue: 0.95),
                    index: 0
                )
                
                tabButton(
                    icon: "figure.walk",
                    label: "Body",
                    color: Color(red: 0.94, green: 0.25, blue: 0.37),
                    index: 1
                )
                
                tabButton(
                    icon: "heart.fill",
                    label: "Baby",
                    color: Color(red: 0.2, green: 0.7, blue: 0.5),
                    index: 2
                )
                
                tabButton(
                    icon: "chart.line.uptrend.xyaxis",
                    label: "Insights",
                    color: Color(red: 0.53, green: 0.81, blue: 0.98),
                    index: 3
                )
            } else {
                // Partner's tabs
                tabButton(
                    icon: "heart.text.square.fill",
                    label: "Mom",
                    color: Color(red: 0.94, green: 0.25, blue: 0.37),
                    index: 0
                )
                
                tabButton(
                    icon: "heart.fill",
                    label: "Baby",
                    color: Color(red: 0.2, green: 0.7, blue: 0.5),
                    index: 1
                )
                
                tabButton(
                    icon: "hands.sparkles.fill",
                    label: "Support",
                    color: Color(red: 0.22, green: 0.72, blue: 0.96),
                    index: 2
                )
                
                tabButton(
                    icon: "chart.line.uptrend.xyaxis",
                    label: "Insights",
                    color: Color(red: 0.53, green: 0.81, blue: 0.98),
                    index: 3
                )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                .stroke(
                    Color(.sRGB, red: 0.18, green: 0.18, blue: 0.24),
                    lineWidth: 1
                )
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: 20,
                    x: 0,
                    y: -5
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private func tabButton(
        icon: String,
        label: String,
        color: Color,
        index: Int
    ) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: selectedTab == index ? 20 : 18))
                    .foregroundColor(
                        selectedTab == index
                            ? color
                            : Color(.sRGB, red: 0.45, green: 0.45, blue: 0.5)
                    )
                
                Text(label)
                    .font(.system(
                        size: selectedTab == index ? 11 : 10,
                        weight: selectedTab == index ? .semibold : .regular
                    ))
                    .foregroundColor(
                        selectedTab == index
                            ? color
                            : Color(.sRGB, red: 0.45, green: 0.45, blue: 0.5)
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                selectedTab == index
                    ? RoundedRectangle(cornerRadius: 16)
                        .fill(color.opacity(0.1))
                    : nil
            )
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserProfile.shared)
}
