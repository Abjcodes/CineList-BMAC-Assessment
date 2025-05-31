import SwiftUI

struct AsyncImageView<Placeholder: View>: View {
    @StateObject private var loader = ImageLoader()
    private let url: URL?
    private let placeholder: Placeholder
    private let imageConfiguration: (Image) -> Image

    init(
        url: URL?,
        @ViewBuilder placeholder: () -> Placeholder,
        @ViewBuilder imageConfiguration: @escaping (Image) -> Image = { $0.resizable() } // Default to resizable
    ) {
        self.url = url
        self.placeholder = placeholder()
        self.imageConfiguration = imageConfiguration
    }

    var body: some View {
        content
            .onAppear {
                loader.load(from: url)
            }
            .onDisappear {
            }
    }

    private var content: some View {
        Group {
            if loader.isLoading {
                placeholder
            } else if let uiImage = loader.image {
                imageConfiguration(Image(uiImage: uiImage))
            } else {
                placeholder
            }
        }
    }
}

// Preview examples
#Preview("Loading State") {
    AsyncImageView(url: URL(string: "https://via.placeholder.com/150/0000FF/808080?Text=Loading...")) {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(ProgressView())
            .aspectRatio(2/3, contentMode: .fit)
    }
    .frame(width: 150, height: 225)
}

#Preview("Loaded Image") {
    AsyncImageView(url: URL(string: "https://image.tmdb.org/t/p/w500/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg")) { // Example Poster
        Rectangle()
            .fill(Color.red.opacity(0.3))
            .overlay(Text("Error"))
            .aspectRatio(2/3, contentMode: .fit)
    }
    .frame(width: 150, height: 225)
}

#Preview("Failed/Invalid URL") {
    AsyncImageView(url: URL(string: "invalid-url")) {
        Rectangle()
            .fill(Color.blue.opacity(0.3))
            .overlay(Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(.white))
            .aspectRatio(2/3, contentMode: .fit)
    }
    .frame(width: 150, height: 225)
} 
