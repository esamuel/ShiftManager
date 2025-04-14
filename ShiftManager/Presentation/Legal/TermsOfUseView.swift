import SwiftUI

struct TermsOfUseView: View {
    
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
                Text("Terms of Use")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 5)
                
                Text("Last updated: \(Date().formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 15)
                
                Text("By downloading or using the ShiftManager app, you agree to be bound by these Terms of Use. If you disagree with any part of these terms, you may not use our app.")
                    .padding(.bottom, 10)
                
                sectionTitle("License")
                
                Text("ShiftManager grants you a limited, non-transferable, non-exclusive license to use the application on any iOS device that you own or control, subject to these Terms and the App Store Terms of Service.")
                
                sectionTitle("Prohibited Uses")
                
                Text("You agree not to:")
                    .padding(.bottom, 5)
                
                bulletPoint("Use the app in any way that violates applicable laws or regulations")
                bulletPoint("Attempt to decompile, reverse engineer, or disassemble the app")
                bulletPoint("Remove or alter any copyright, trademark, or other proprietary notices")
                bulletPoint("Transfer, distribute, or make the app available over a network where it could be used by multiple devices")
                
                sectionTitle("Limitations of Liability")
                
                Text("ShiftManager and its developers shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use or inability to use the app. This includes but is not limited to:")
                    .padding(.bottom, 5)
                
                bulletPoint("Data loss or corruption")
                bulletPoint("Financial losses due to calculation errors")
                bulletPoint("Any errors in time tracking or scheduling")
                bulletPoint("System failures or service interruptions")
                
                sectionTitle("Accuracy of Information")
                
                Text("While we strive to provide accurate calculations and information, ShiftManager is provided 'as is' without warranty of any kind. You are responsible for verifying the accuracy of all calculations and information.")
                
                sectionTitle("Updates and Changes")
                
                Text("We may update our app and these Terms of Use from time to time. We will notify you of any changes by posting the new Terms of Use in the app. Your continued use of the app after such modifications will constitute your acknowledgment of the modified Terms and agreement to abide by them.")
                
                sectionTitle("Termination")
                
                Text("We may terminate or suspend your access to the app immediately, without prior notice, for any reason whatsoever, including without limitation if you breach these Terms of Use.")
                
                sectionTitle("Governing Law")
                
                Text("These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which the developer operates, without regard to its conflict of law provisions.")
                
                sectionTitle("Contact Us")
                
                Text("If you have any questions about these Terms of Use, please contact us at:")
                Text("support@shiftmanager.app")
                    .padding(.top, 5)
            }
            .padding()
        }
        .navigationTitle("Terms of Use")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TermsOfUseView()
    }
} 