import SwiftUI

struct VideoTutorialButton: View {
    let title: String
    let videoURL: URL
    
    var body: some View {
        Link(destination: videoURL) {
            HStack {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 20))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.blue)
            .padding(.vertical, 4)
        }
    }
}

struct VideoTutorialButton_Previews: PreviewProvider {
    static var previews: some View {
        VideoTutorialButton(
            title: "Watch Tutorial",
            videoURL: URL(string: "https://www.youtube.com")!
        )
    }
}
