import SwiftUI

struct FeedbackManagementView: View {
    @StateObject private var repository = FeedbackRepository()
    @State private var feedbackList: [FeedbackModel] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingDeleteAlert = false
    @State private var feedbackToDelete: FeedbackModel?
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading feedback...".localized)
            } else if let error = errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    Text("Error".localized)
                        .font(.headline)
                    Text(error)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry".localized) {
                        loadFeedback()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if feedbackList.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "tray")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No Feedback Yet".localized)
                        .font(.headline)
                    Text("Feedback submitted by users will appear here.".localized)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                List {
                    ForEach(feedbackList) { feedback in
                        FeedbackRowView(feedback: feedback)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    feedbackToDelete = feedback
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete".localized, systemImage: "trash")
                                }
                            }
                    }
                }
                .refreshable {
                    loadFeedback()
                }
            }
        }
        .navigationTitle("Feedback History".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        deleteAllFeedback()
                    } label: {
                        Label("Delete All".localized, systemImage: "trash")
                    }
                    
                    Button {
                        exportFeedbackAsCSV()
                    } label: {
                        Label("Export as CSV".localized, systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Delete Feedback?".localized, isPresented: $showingDeleteAlert) {
            Button("Cancel".localized, role: .cancel) { }
            Button("Delete".localized, role: .destructive) {
                if let feedback = feedbackToDelete {
                    deleteFeedback(feedback)
                }
            }
        } message: {
            Text("This action cannot be undone.".localized)
        }
        .onAppear {
            loadFeedback()
        }
        .id(themeManager.refreshID)
        .withAppTheme()
    }
    
    private func loadFeedback() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                feedbackList = try await repository.fetchAllFeedback()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    private func deleteFeedback(_ feedback: FeedbackModel) {
        Task {
            do {
                try await repository.deleteFeedback(feedbackId: feedback.id)
                loadFeedback()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func deleteAllFeedback() {
        Task {
            do {
                try await repository.deleteAllFeedback()
                loadFeedback()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func exportFeedbackAsCSV() {
        let csvString = generateCSV()
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("feedback_export.csv")
        
        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            errorMessage = "Failed to export: \(error.localizedDescription)"
        }
    }
    
    private func generateCSV() -> String {
        var csv = "ID,Rating,Category,Date,Sent via Email,App Version,Device,Comment\n"
        
        for feedback in feedbackList {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            
            let row = [
                feedback.id.uuidString,
                String(feedback.rating),
                feedback.category.rawValue,
                dateFormatter.string(from: feedback.createdAt),
                feedback.isSentViaEmail ? "Yes" : "No",
                feedback.appVersion,
                feedback.deviceModel,
                "\"" + feedback.comment.replacingOccurrences(of: "\"", with: "\"\"") + "\""
            ].joined(separator: ",")
            
            csv += row + "\n"
        }
        
        return csv
    }
}

struct FeedbackRowView: View {
    let feedback: FeedbackModel
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Rating stars
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= feedback.rating ? "star.fill" : "star")
                            .foregroundColor(star <= feedback.rating ? .yellow : .gray)
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                // Sent indicator
                if feedback.isSentViaEmail {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
                
                // Date
                Text(feedback.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Category
            Text(feedback.category.displayName)
                .font(.headline)
            
            // Comment preview or full
            Text(feedback.comment)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(isExpanded ? nil : 2)
            
            // Expand/Collapse button
            if feedback.comment.count > 100 {
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Text(isExpanded ? "Show Less".localized : "Show More".localized)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            // Metadata
            HStack {
                Text("App: \(feedback.appVersion)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text(feedback.deviceModel)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        FeedbackManagementView()
    }
}
