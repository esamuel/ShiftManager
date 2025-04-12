import SwiftUI

public struct GuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Welcome Section
                    GuideSection(title: "Welcome to ShiftManager", icon: "hand.wave.fill") {
                        Text("ShiftManager helps you track your work shifts, calculate wages, and manage overtime. This guide will walk you through all the app's features.")
                            .padding(.bottom)
                    }
                    
                    // Settings Section
                    GuideSection(title: "1. Initial Setup", icon: "gearshape.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Before you start, set up your basic information:")
                                .padding(.bottom, 4)
                            
                            BulletPoint("Go to Settings → Personal Information and:")
                            IndentedBulletPoint("Enter your username")
                            IndentedBulletPoint("Tap 'Save Changes' to save your information")
                            BulletPoint("Navigate to Shift Settings and set your:")
                            IndentedBulletPoint("Hourly wage")
                            IndentedBulletPoint("Tax deduction percentage")
                            IndentedBulletPoint("Base hours for weekdays and special days")
                            IndentedBulletPoint("Work week start day (Sunday/Monday)")
                        }
                    }
                    
                    // Overtime Rules Section
                    GuideSection(title: "2. Overtime Rules", icon: "clock.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Configure your overtime rules:")
                                .padding(.bottom, 4)
                            
                            BulletPoint("Set base hours for regular weekdays and special days")
                            BulletPoint("Add overtime rules with:")
                            IndentedBulletPoint("Hours threshold (when overtime starts)")
                            IndentedBulletPoint("Rate multiplier (e.g., 1.5x for 150%)")
                            IndentedBulletPoint("Choose if rule applies to special days")
                        }
                    }
                    
                    // Shift Management Section
                    GuideSection(title: "3. Managing Shifts", icon: "calendar") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add and manage your shifts:")
                                .padding(.bottom, 4)
                            
                            BulletPoint("Tap the '+' button to add a new shift")
                            BulletPoint("Set start and end times")
                            BulletPoint("Mark special days with the star icon")
                            BulletPoint("View and edit existing shifts")
                            BulletPoint("Delete shifts using the delete button (trash icon)")
                        }
                    }
                    
                    // Reports Section
                    GuideSection(title: "4. Reports", icon: "chart.bar.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("View and export your work data:")
                                .padding(.bottom, 4)
                            
                            BulletPoint("Switch between weekly and monthly views")
                            BulletPoint("View total hours and wages")
                            BulletPoint("See breakdown of regular and overtime hours")
                            BulletPoint("Export reports to PDF")
                            BulletPoint("Search shifts by date range")
                        }
                    }
                    
                    // Tips Section
                    GuideSection(title: "5. Tips & Tricks", icon: "lightbulb.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Make the most of ShiftManager:")
                                .padding(.bottom, 4)
                            
                            BulletPoint("Use the search feature to find specific shifts")
                            BulletPoint("Export reports regularly for record-keeping")
                            BulletPoint("Keep your overtime rules up to date")
                            BulletPoint("Mark special days to ensure correct wage calculations")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("User Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct GuideSection<Content: View>: View {
    let title: String
    let icon: String
    let content: () -> Content
    
    init(title: String, icon: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.purple)
                    .font(.title2)
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            content()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

struct BulletPoint: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text("•")
                .foregroundColor(.purple)
            Text(text)
        }
    }
}

struct IndentedBulletPoint: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text("  •")
                .foregroundColor(.purple)
            Text(text)
        }
        .padding(.leading, 16)
    }
}

#Preview {
    GuideView()
} 