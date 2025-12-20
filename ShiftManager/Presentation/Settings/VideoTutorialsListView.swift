import SwiftUI

struct VideoTutorialsListView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(Tutorial.allTutorials) { tutorial in
                Link(destination: tutorial.url) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "play.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 16))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tutorial.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(tutorial.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Video Tutorials".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .onAppear {
            UINavigationBar.appearance().backItem?.backButtonTitle = ""
            UINavigationBar.appearance().topItem?.backButtonTitle = ""
        }
    }
}

struct VideoTutorialsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VideoTutorialsListView()
        }
    }
}
