import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 24) {
            // Worker cartoon image
            Image("NoShiftsIllustration")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 180)
                .padding(.bottom, 8)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 300)
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView(
        title: "No Shifts This Week",
        message: "Looks like you don't have any shifts scheduled for this week."
    )
} 