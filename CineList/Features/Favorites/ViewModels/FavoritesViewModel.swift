import SwiftUI
import Combine

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favoriteMovies: [Movie] = [] 
    @Published var searchText: String = ""
    
    @Published var isLoading: Bool = false
    @Published var currentErrorMessage: String? = nil

    var filteredMovies: [Movie] {
        if searchText.isEmpty {
            return favoriteMovies
        } else {
            return favoriteMovies.filter { movie in
                movie.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private let favoriteService = FavoriteService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Subscribe to changes in FavoriteService's published list
        favoriteService.$favoriteMovies
            .receive(on: DispatchQueue.main) // Ensure updates are on the main thread
            .sink { [weak self] loadedFavorites in
                self?.favoriteMovies = loadedFavorites
                self?.isLoading = false // Assuming loading is done once we get the list
                if loadedFavorites.isEmpty && self?.searchText.isEmpty ?? true {
                    self?.currentErrorMessage = "You haven't added any movies to your favorites yet."
                } else {
                    self?.currentErrorMessage = nil // Clear message if there are favorites or search text
                }
            }
            .store(in: &cancellables)
        
    }

    func toggleFavorite(movie: Movie) {
        
        if favoriteService.isFavorite(movieId: movie.id) {
            favoriteService.removeFavorite(movieId: movie.id)
        } else {
       
            var movieToAdd = movie
            movieToAdd.isFavorite = true
            favoriteService.addFavorite(movie: movieToAdd)
        }
    }
    
    func onAppear() {
        // self.searchText = "" // Optional: Reset search text on appear
        // The view model now reactively updates based on FavoriteService.
        // If an explicit refresh is ever needed, FavoriteService could expose a method.
    }
} 
