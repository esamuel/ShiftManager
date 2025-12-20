import SwiftUI

struct PrivacyPolicyView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    
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
                Text("premium_privacy_full_content".localized)
                    .padding(.bottom, 5)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy".localized)
        .id(localizationManager.refreshID)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        PrivacyPolicyView()
    }
} 