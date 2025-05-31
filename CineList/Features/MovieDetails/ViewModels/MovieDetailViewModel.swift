import SwiftUI
import Combine

@MainActor // Ensure UI updates are on the main thread
class MovieDetailViewModel: ObservableObject {
    @Published var movie: Movie 
    @Published var isFavorite: Bool

    private let favoriteService = FavoriteService.shared
    private var cancellables = Set<AnyCancellable>()
    private let movieId: Int

    init(movie: Movie) {
        self.movieId = movie.id
        self.movie = movie
        self.isFavorite = favoriteService.isFavorite(movieId: self.movieId)
        if self.movie.isFavorite != self.isFavorite {
            self.movie.isFavorite = self.isFavorite
        }
        
        favoriteService.$favoriteMovies
            .receive(on: DispatchQueue.main)
            .map { favoritesList -> Bool in
              
                favoritesList.contains(where: { $0.id == self.movieId })
            }
            .assign(to: &$isFavorite)
        
     
        $isFavorite
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newFavoriteStatus in
                if self?.movie.isFavorite != newFavoriteStatus {
                    self?.movie.isFavorite = newFavoriteStatus
                }
            }
            .store(in: &cancellables)
    }

    func toggleFavorite() {
       
        if self.isFavorite {
            favoriteService.removeFavorite(movieId: self.movieId)
            print("Movie '\(movie.title)' removed from favorites via DetailView.")
        } else {
            favoriteService.addFavorite(movie: self.movie) 
            print("Movie '\(movie.title)' marked as favorite via DetailView.")
        }
        
    }
} 
