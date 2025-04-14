import SwiftUI

public struct GuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var animateContent = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Welcome Section
                    GuideSection(title: "Welcome to ShiftManager".localized, iconName: "hand.wave.fill") {
                        Text("ShiftManager helps you track your work shifts, calculate wages, and manage overtime. This guide will walk you through all the app's features.".localized)
                            .padding(.bottom)
                    }
                    
                    // Settings Section
                    GuideSection(title: "1. Initial Setup".localized, iconName: "gearshape.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Before you start, set up your basic information:".localized)
                                .padding(.bottom, 4)
                            
                            BulletPoint("Go to Settings → Personal Information and:".localized)
                            IndentedBulletPoint("Enter your username".localized)
                            IndentedBulletPoint("Tap 'Save Changes' to save your information".localized)
                            BulletPoint("Navigate to Shift Settings and set your:".localized)
                            IndentedBulletPoint("Hourly wage".localized)
                            IndentedBulletPoint("Tax deduction percentage".localized)
                            IndentedBulletPoint("Base hours for weekdays and special days".localized)
                            IndentedBulletPoint("Work week start day (Sunday/Monday)".localized)
                        }
                    }
                    
                    // Overtime Rules Section
                    GuideSection(title: "2. Overtime Rules".localized, iconName: "clock.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Configure your overtime rules:".localized)
                                .padding(.bottom, 4)
                            
                            BulletPoint("Set base hours for regular weekdays and special days".localized)
                            BulletPoint("Add overtime rules with:".localized)
                            IndentedBulletPoint("Hours threshold (when overtime starts)".localized)
                            IndentedBulletPoint("Rate multiplier (e.g., 1.5x for 150%)".localized)
                            IndentedBulletPoint("Choose if rule applies to special days".localized)
                        }
                    }
                    
                    // Shift Management Section
                    GuideSection(title: "3. Managing Shifts".localized, iconName: "calendar") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add and manage your shifts:".localized)
                                .padding(.bottom, 4)
                            
                            BulletPoint("Tap the '+' button to add a new shift".localized)
                            BulletPoint("Set start and end times".localized)
                            BulletPoint("Mark special days with the star icon".localized)
                            BulletPoint("View and edit existing shifts".localized)
                            BulletPoint("Delete shifts using the delete button (trash icon)".localized)
                        }
                    }
                    
                    // Reports Section
                    GuideSection(title: "4. Reports".localized, iconName: "chart.bar.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("View and export your work data:".localized)
                                .padding(.bottom, 4)
                            
                            BulletPoint("Switch between weekly and monthly views".localized)
                            BulletPoint("View total hours and wages".localized)
                            BulletPoint("See breakdown of regular and overtime hours".localized)
                            BulletPoint("Export reports to PDF".localized)
                            BulletPoint("Search shifts by date range".localized)
                        }
                    }
                    
                    // Tips Section
                    GuideSection(title: "5. Tips & Tricks".localized, iconName: "lightbulb.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Make the most of ShiftManager:".localized)
                                .padding(.bottom, 4)
                            
                            BulletPoint("Use the search feature to find specific shifts".localized)
                            BulletPoint("Export reports regularly for record-keeping".localized)
                            BulletPoint("Keep your overtime rules up to date".localized)
                            BulletPoint("Mark special days to ensure correct wage calculations".localized)
                        }
                    }
                }
                .padding()
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
            }
            .navigationTitle("User Guide".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done".localized)
                            .fontWeight(.medium)
                            .foregroundColor(.purple)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Close Guide".localized)
                }
            }
        }
        .onAppear {
            // Animate content appearance
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                animateContent = true
            }
        }
    }
}

struct GuideSection<Content: View>: View {
    let title: String
    let iconName: String
    let content: () -> Content
    
    init(title: String, iconName: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.iconName = iconName
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconName)
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