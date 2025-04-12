import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Upcoming Shifts Button
                NavigationLink(destination: ShiftManagerView(viewModel: ShiftManagerViewModel())) {
                    MenuButton(
                        title: "Upcoming Shifts",
                        icon: "calendar",
                        color: Color.orange
                    )
                }
                
                // Shift Manager Button
                NavigationLink(destination: ShiftManagerView(viewModel: ShiftManagerViewModel())) {
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
                NavigationLink(destination: OvertimeRulesView()) {
                    MenuButton(
                        title: "Overtime Rules",
                        icon: "clock.fill",
                        color: Color(red: 0.8, green: 0.7, blue: 1.0)
                    )
                }
                
                // Settings Button
                NavigationLink(destination: SettingsView()) {
                    MenuButton(
                        title: "Settings",
                        icon: "gearshape.fill",
                        color: Color(red: 0.8, green: 0.7, blue: 1.0)
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Shift View")
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
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
    HomeView(viewModel: HomeViewModel())
} 