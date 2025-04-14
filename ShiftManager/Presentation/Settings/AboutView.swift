import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // App logo and name
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "clock.badge.checkmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                        
                        Text("Shift Manager")
                            .font(.title)
                            .bold()
                        
                        Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 30)
                
                // App description
                Group {
                    Text("About Shift Manager")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    Text("Shift Manager is a comprehensive tool designed to help you track your work hours, calculate earnings, and manage your work schedule efficiently.")
                    
                    Text("Key Features")
                        .font(.headline)
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                    
                    featureItem(icon: "clock", title: "Time Tracking", description: "Log your shifts with precise start and end times")
                    featureItem(icon: "dollarsign.circle", title: "Earnings Calculator", description: "Calculate your wages with support for overtime and various tax rates")
                    featureItem(icon: "calendar", title: "Schedule Management", description: "View your shifts in daily, weekly, or monthly formats")
                    featureItem(icon: "bell", title: "Reminders", description: "Set notifications for upcoming shifts")
                    featureItem(icon: "chart.bar", title: "Statistics", description: "Analyze your work patterns and earnings over time")
                    
                    Text("Developer Information")
                        .font(.headline)
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                    
                    Text("Shift Manager is developed and maintained by a team passionate about creating tools that make work-life management easier.")
                }
                
                // Contact and support
                Group {
                    Button {
                        openURL(URL(string: "mailto:support@shiftmanager.app")!)
                    } label: {
                        Label("Contact Support", systemImage: "envelope")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    
                    // Legal information buttons
                    NavigationLink(destination: PrivacyPolicyView()) {
                        HStack {
                            Image(systemName: "lock.shield")
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: TermsOfUseView()) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Terms of Use")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func featureItem(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .frame(width: 24, height: 24)
                .foregroundColor(.blue)
                .padding(.trailing, 5)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
} 