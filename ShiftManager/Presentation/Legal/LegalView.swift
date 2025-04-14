import SwiftUI

struct LegalView: View {
    var body: some View {
        List {
            NavigationLink(destination: PrivacyPolicyView()) {
                HStack {
                    Image(systemName: "lock.shield")
                        .foregroundColor(.blue)
                        .font(.system(size: 22))
                    
                    Text("Privacy Policy")
                        .font(.body)
                        .padding(.leading, 8)
                }
                .padding(.vertical, 8)
            }
            
            NavigationLink(destination: TermsOfUseView()) {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.blue)
                        .font(.system(size: 22))
                    
                    Text("Terms of Use")
                        .font(.body)
                        .padding(.leading, 8)
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Legal")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LegalView()
    }
} 