import SwiftUI
import Combine // For ObservableObject, @Published

@MainActor // Ensure UI updates are on the main thread
class ImageLoader: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var url: URL?
    private var cancellable: AnyCancellable?
    private let imageCache = ImageCache.shared

    init() {}

    func load(from url: URL?) {
        guard let url = url else {
            self.errorMessage = "Invalid URL"
            self.image = nil // Clear previous image if any
            return
        }
        
        self.url = url // Store the URL for potential retry or reload logic
        self.isLoading = true
        self.errorMessage = nil
        self.image = nil // Clear previous image before loading new one

        // Check cache first
        if let cachedImage = imageCache.image(for: url) {
            self.image = cachedImage
            self.isLoading = false
            return
        }

        // If not in cache, download
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loadedImage in
                guard let self = self else { return }
                self.isLoading = false
                if let loadedImage = loadedImage {
                    self.image = loadedImage
                    self.imageCache.setImage(loadedImage, for: url)
                } else {
                    self.errorMessage = "Failed to load image from \(url.lastPathComponent)."
                }
            }
    }
    
    func cancel() {
        cancellable?.cancel()
        isLoading = false
    }
} 
