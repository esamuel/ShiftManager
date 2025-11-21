import SwiftUI

struct PremiumPrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localizationManager = LocalizationManager.shared
    
    private var isRTL: Bool {
        localizationManager.currentLanguage == "he" || localizationManager.currentLanguage == "ar"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: isRTL ? .trailing : .leading, spacing: 20) {
                    Text("Privacy Policy".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                        .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                    
                    VStack(alignment: isRTL ? .trailing : .leading, spacing: 8) {
                        Text("premium_privacy_key_principle".localized)
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Text("premium_privacy_key_message".localized)
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
                    
                    Text("premium_privacy_full_content".localized)
                        .multilineTextAlignment(isRTL ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                    
                    VStack(alignment: isRTL ? .trailing : .leading, spacing: 8) {
                        Text("premium_privacy_summary_title".localized)
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Text("premium_privacy_summary_content".localized)
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
                    
                    Text("premium_privacy_last_updated".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                }
                .padding()
            }
            .navigationTitle("Privacy Policy".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done".localized) {
                        dismiss()
                    }
                }
            }
        }
        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
    }
}

#Preview {
    PremiumPrivacyView()
}


