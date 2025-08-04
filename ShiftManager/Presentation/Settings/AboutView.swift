import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var localizationManager = LocalizationManager.shared
    
    init() {
        print("Debug: Localized About title is \("About".localized) and current locale is \(Locale.current)")
    }
    
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
                    Text("About Shift Manager".localized)
                        .font(.headline)
                        .padding(.bottom, 5)

                    Text("About_Description".localized)

                    Text("Key Features".localized)
                        .font(.headline)
                        .padding(.top, 10)
                        .padding(.bottom, 5)

                    // Removed "Time Tracking" as it was not part of the original translation batch
                    featureItem(icon: "dollarsign.circle", title: "Earnings Calculator".localized, description: "Earnings Calculator Description".localized)
                    featureItem(icon: "calendar", title: "Schedule Management".localized, description: "Schedule Management Description".localized)
                    featureItem(icon: "bell", title: "Reminders".localized, description: "Reminders Description".localized)
                    featureItem(icon: "chart.bar", title: "Statistics".localized, description: "Statistics Description".localized)

                    Text("Developer Information".localized)
                        .font(.headline)
                        .padding(.top, 10)
                        .padding(.bottom, 5)

                    Text("Developer Description".localized)
                }
                
                // Contact and support
                Group {
                    Button {
                        openURL(URL(string: "mailto:support@shiftmanager.app")!)
                    } label: {
                        Label("Contact Support".localized, systemImage: "envelope")
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
                            Text("Privacy Policy".localized)
                                .environment(\.layoutDirection, .rightToLeft)  // For Hebrew RTL support
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
                            Text("Terms of Use".localized)
                                .environment(\.layoutDirection, .rightToLeft)  // For Hebrew RTL support
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
        .id(localizationManager.refreshID)
        .navigationTitle("About".localized)
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