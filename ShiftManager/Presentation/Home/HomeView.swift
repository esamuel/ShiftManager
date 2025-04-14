import SwiftUI

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingUpcomingShifts = true
    @State private var showingGuide = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Title with custom font size
                HStack {
                    Text("Shift Manager".localized)
                        .font(.system(size: 32, weight: .bold))
                    
                    Spacer()
                    
                    // Help button
                    Button(action: { 
                        showingGuide = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.title2)
                            .foregroundColor(.purple)
                            .padding(8)
                            .background(Color.purple.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Help".localized)
                    .help("Open User Guide".localized)
                }
                .padding(.top)
                .padding(.horizontal)
                
                // Menu Buttons
                ScrollView {
                    VStack(spacing: 16) {
                        // Home Button (Main Screen)
                        Button(action: { showingUpcomingShifts = true }) {
                            MenuButton(
                                title: "Coming Shifts".localized,
                                icon: "house.fill",
                                color: Color(red: 0.8, green: 0.7, blue: 1.0)
                            )
                        }
                        
                        // Shift Manager Button
                        NavigationLink(destination: ShiftManagerView()) {
                            MenuButton(
                                title: "Shift Manager".localized,
                                icon: "briefcase.fill",
                                color: Color(red: 0.8, green: 0.7, blue: 1.0)
                            )
                        }
                        
                        // Reports Button
                        NavigationLink(destination: ReportView()) {
                            MenuButton(
                                title: "Reports".localized,
                                icon: "chart.bar.fill",
                                color: Color(red: 0.8, green: 0.7, blue: 1.0)
                            )
                        }
                        
                        // Guide Button
                        NavigationLink(destination: GuideView()) {
                            MenuButton(
                                title: "Guide".localized,
                                icon: "info.circle.fill",
                                color: Color(red: 0.8, green: 0.7, blue: 1.0)
                            )
                        }
                        
                        // Overtime Rules Button
                        NavigationLink(destination: OvertimeRulesView()) {
                            MenuButton(
                                title: "Overtime Rules".localized,
                                icon: "clock.fill",
                                color: Color(red: 0.8, green: 0.7, blue: 1.0)
                            )
                        }
                        
                        // Settings Button
                        NavigationLink(destination: SettingsView()) {
                            MenuButton(
                                title: "Settings".localized,
                                icon: "gearshape.fill",
                                color: Color(red: 0.8, green: 0.7, blue: 1.0)
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingUpcomingShifts) {
            NavigationView {
                UpcomingShiftsView()
                    .navigationTitle("Upcoming Shifts".localized)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done".localized) {
                                showingUpcomingShifts = false
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showingGuide) {
            GuideView()
        }
    }
}

public struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    
    public init(title: String, icon: String, color: Color) {
        self.title = title
        self.icon = icon
        self.color = color
    }
    
    public var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
            
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(color.opacity(0.2))
        .cornerRadius(12)
    }
}

#Preview {
    HomeView()
} 