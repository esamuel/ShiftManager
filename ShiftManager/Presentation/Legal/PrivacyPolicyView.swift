import SwiftUI

struct PrivacyPolicyView: View {
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .padding(.top, 10)
            .padding(.bottom, 5)
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top) {
            Text("•")
                .padding(.trailing, 5)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 1)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Privacy Policy")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 5)
                
                Text("Last updated: \(Date().formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 15)
                
                Text("This Privacy Policy describes how your personal information is collected, used, and shared when you use the ShiftManager app.")
                    .padding(.bottom, 10)
                
                sectionTitle("Information We Collect")
                
                Text("When you use ShiftManager, we collect the following types of information:")
                    .padding(.bottom, 5)
                
                bulletPoint("Shift information you enter, including dates, times, locations, and wages")
                bulletPoint("Tax rate information you provide for calculating net income")
                bulletPoint("App usage data and preferences to improve your experience")
                bulletPoint("Device information necessary for the app's functionality")
                
                sectionTitle("How We Use Your Information")
                
                bulletPoint("To provide and maintain the app's functionality")
                bulletPoint("To calculate your work hours, shifts, and earnings")
                bulletPoint("To save your preferences and settings")
                bulletPoint("To improve and optimize the app experience")
                
                sectionTitle("Data Storage")
                
                Text("ShiftManager stores your data locally on your device. We do not transmit or store your shift data on external servers unless you explicitly opt to use cloud backup features.")
                
                sectionTitle("Third-Party Services")
                
                Text("The app may use third-party services for analytics and crash reporting. These services collect anonymous usage data to help us improve the app and do not include your personal shift information.")
                
                sectionTitle("Your Rights")
                
                Text("You can access, change, or delete your data at any time through the app settings. Since data is stored locally, deleting the app will remove all your data.")
                
                sectionTitle("Changes to Privacy Policy")
                
                Text("We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy in the app and updating the \"Last Updated\" date.")
                
                sectionTitle("Contact Us")
                
                Text("If you have questions about this Privacy Policy, please contact us at:")
                Text("support@shiftmanager.app")
                    .padding(.top, 5)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
} 