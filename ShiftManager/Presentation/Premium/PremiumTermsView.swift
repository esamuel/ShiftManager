import SwiftUI

struct PremiumTermsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localizationManager = LocalizationManager.shared
    
    private var isRTL: Bool {
        localizationManager.currentLanguage == "he" || localizationManager.currentLanguage == "ar"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: isRTL ? .trailing : .leading, spacing: 20) {
                    Text("Terms of Service".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                        .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                    
                    Text("premium_terms_full_content".localized)
                        .multilineTextAlignment(isRTL ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                    
                    Text("premium_terms_last_updated".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                }
                .padding()
            }
            .navigationTitle("Terms of Service".localized)
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
    PremiumTermsView()
}


