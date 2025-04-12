import SwiftUI

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingUpcomingShifts = true
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Title with custom font size
                Text("Shift Manager")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top)
                
                // Menu Buttons
                ScrollView {
                    VStack(spacing: 16) {
                        // Home Button (Main Screen)
                        Button(action: { showingUpcomingShifts = true }) {
                            MenuButton(
                                title: "Home",
                                icon: "house.fill",
                                color: Color(red: 0.8, green: 0.7, blue: 1.0)
                            )
                        }
                        
                        // Shift Manager Button
                        NavigationLink(destination: ShiftManagerView()) {
                            MenuButton(
                                title: "Shift Manager",
                                icon: "briefcase.fill",
                                color: Color(red: 0.8, green: 0.7, blue: 1.0)
                            )
                        }
                        
                        // Reports Button
                        NavigationLink(destination: ReportView()) {
                            MenuButton(
                                title: "Reports",
                                icon: "chart.bar.fill",
                                color: Color(red: 0.8, green: 0.7, blue: 1.0)
                            )
                        }
                        
                        // Guide Button
                        NavigationLink(destination: Text("Guide View - Coming Soon")) {
                            MenuButton(
                                title: "Guide",
                                icon: "info.circle.fill",
                                color: Color(red: 0.8, green: 0.7, blue: 1.0)
                            )
                        }
                        
                        // Overtime Rules Button
                        NavigationLink(destination: SettingsView()) {
                            MenuButton(
                                title: "Overtime Rules",
                                icon: "clock.fill",
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
                    .navigationTitle("Upcoming Shifts")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingUpcomingShifts = false
                            }
                        }
                    }
            }
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