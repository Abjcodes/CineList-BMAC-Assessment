import Foundation
import Combine

class FavoriteService: ObservableObject {
    static let shared = FavoriteService()
    private let favoritesKey = "favoriteMovies"
    private let userDefaults = UserDefaults.standard

    @Published var favoriteMovies: [Movie] = []

    private init() {
        loadFavoritesFromUserDefaults()
    }

    // MARK: - Model Update & Persistence

    private func loadFavoritesFromUserDefaults() {
        guard let data = userDefaults.data(forKey: favoritesKey) else {
            self.favoriteMovies = []
            return
        }
        do {
            let movies = try JSONDecoder().decode([Movie].self, from: data)
            self.favoriteMovies = movies
        } catch {
            print("Error decoding favorite movies from UserDefaults: \(error.localizedDescription)")
            self.favoriteMovies = []
        }
    }

    private func persistFavorites() {
        do {
            let data = try JSONEncoder().encode(self.favoriteMovies)
            userDefaults.set(data, forKey: favoritesKey)
        } catch {
            print("Error encoding favorite movies to UserDefaults: \(error.localizedDescription)")
        }
    }

    // MARK: - Public Methods for Modifying Favorites

    func addFavorite(movie: Movie) {
        guard !isFavorite(movieId: movie.id) else {
            return
        }
        var movieToAdd = movie
        movieToAdd.isFavorite = true
        
        favoriteMovies.append(movieToAdd)
        persistFavorites()
    }

    func removeFavorite(movieId: Int) {
        if let index = favoriteMovies.firstIndex(where: { $0.id == movieId }) {
            favoriteMovies.remove(at: index)
            persistFavorites()
        } else {
        }
    }

    // MARK: - Public Methods for Checking Status

    func isFavorite(movieId: Int) -> Bool {
        return favoriteMovies.contains(where: { $0.id == movieId })
    }
    
    // Convenience overload
    func isFavorite(movie: Movie) -> Bool {
        return isFavorite(movieId: movie.id)
    }

    // MARK: - Utility
    
    // Kept for convenience, e.g., debugging or testing.
    func getFavoriteMoviesFromUserDefaults() -> [Movie] {
        guard let data = userDefaults.data(forKey: favoritesKey) else {
            return []
        }
        do {
            return try JSONDecoder().decode([Movie].self, from: data)
        } catch {
            print("Error decoding favorite movies: \(error.localizedDescription)")
            return []
        }
    }

    func clearAllFavorites() {
        favoriteMovies = []
        persistFavorites() 
    }
} 
