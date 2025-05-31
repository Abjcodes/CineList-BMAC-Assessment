import Foundation
import Combine // For ObservableObject and @Published

@MainActor // Ensures UI updates are on the main thread
class MovieFeedViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var isFetchingNextPage: Bool = false
    
    @Published var availableGenres: [Genre] = [Genre.all] // Start with "All Genres"
    @Published var selectedGenre: Genre = Genre.all {
        didSet {
            // Only fetch if the new genre is actually different from the old one.
            if oldValue.id != selectedGenre.id {
                Task {
                    await self.fetchMoviesByGenreOrPopular(isSearchTriggeredByTextChange: false)
                }
            } else {
                print("Selected genre is the same as the current one. No API call needed.")
            }
        }
    }

    private var currentPage = 1
    private var totalPages = 1
    var currentSearchQuery: String? = nil

    private let tmdbService: TMDBServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private let favoriteService = FavoriteService.shared

    init(tmdbService: TMDBServiceProtocol = TMDBService()) {
        self.tmdbService = tmdbService
        setupSearchDebounce()
        setupFavoriteServiceSubscription() 
        Task {
            await fetchGenres()
        }
    }

    private func setupFavoriteServiceSubscription() {
        favoriteService.$favoriteMovies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateDisplayedMovieFavoriteStates()
            }
            .store(in: &cancellables)
    }

    private func updateDisplayedMovieFavoriteStates() {
        let updatedMovies = self.movies.map { movie -> Movie in
            var mutableMovie = movie
            mutableMovie.isFavorite = favoriteService.isFavorite(movieId: movie.id)
            return mutableMovie
        }
        
        if self.movies != updatedMovies {
            self.movies = updatedMovies
        }
    }

    private func updateFavoriteStatusOnFetched(movies: [Movie]) -> [Movie] {
        return movies.map { movie -> Movie in
            var mutableMovie = movie
            mutableMovie.isFavorite = favoriteService.isFavorite(movieId: movie.id)
            return mutableMovie
        }
    }

    private func fetchGenres() async {
        do {
            let response = try await tmdbService.fetchMovieGenres()
            let fetchedGenres = response.genres.map { Genre(dto: $0) }
            // Prepend "All Genres" to the fetched list if it's not already there
            if !fetchedGenres.contains(Genre.all) {
                self.availableGenres = [Genre.all] + fetchedGenres
            } else {
                self.availableGenres = fetchedGenres
            }
        } catch {
            print("Failed to fetch genres: \(error.localizedDescription)")
            // Keep the default [Genre.all] if fetching fails
        }
    }

    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .seconds(0.8), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                Task {
                    self.currentSearchQuery = query.isEmpty ? nil : query
                    await self.fetchMoviesByGenreOrPopular(isSearchTriggeredByTextChange: true)
                }
            }
            .store(in: &cancellables)
    }

   
    func fetchMoviesByGenreOrPopular(isSearchTriggeredByTextChange: Bool = false) async {
        currentPage = 1
        if !isSearchTriggeredByTextChange {
            isLoading = true
        }
        errorMessage = nil

        do {
            let response: MovieListResponseDTO
            if let searchQuery = currentSearchQuery, !searchQuery.isEmpty {
                // If searching, genre filtering is secondary or not directly supported by /search/movie.
                // For now, search overrides genre. A more complex setup might use /discover with a keyword.
                print("Performing search for: \(searchQuery). Selected genre (ID: \(selectedGenre.id)) ignored by /search/movie endpoint.")
                response = try await tmdbService.searchMovies(query: searchQuery, page: currentPage)
            } else if selectedGenre.id != Genre.all.id { // Genre selected (and not "All Genres")
                print("Fetching movies for genre: \(selectedGenre.name) (ID: \(selectedGenre.id))")
                response = try await tmdbService.discoverMovies(genreId: selectedGenre.id, page: currentPage)
            } else { // No search, no specific genre -> fetch popular (or discover without genre)
                 // Discover without a specific genre often defaults to popular or can be configured.
                print("Fetching popular movies (no specific genre, or 'All Genres' selected).")
                response = try await tmdbService.discoverMovies(genreId: nil, page: currentPage) // Or fetchPopularMovies
            }

            let fetchedMovies = response.results.map { Movie(dto: $0) }
            self.movies = updateFavoriteStatusOnFetched(movies: fetchedMovies)
            self.totalPages = response.totalPages
        } catch let error as NetworkError {
            errorMessage = "Failed to fetch movies: \(error.localizedDescription)"
            print("NetworkError fetching movies: \(error)")
            self.movies = [] // Clear movies on error
        } catch {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            print("Unexpected error fetching movies: \(error)")
            self.movies = [] // Clear movies on error
        }
        isLoading = false
    }

    // performSearch and fetchInitialPopularMovies can be refactored into fetchMoviesByGenreOrPopular
    // For now, fetchInitialPopularMovies can be the entry point on appear
    func fetchInitialMovies() async {
        currentSearchQuery = nil // Reset search query
        selectedGenre = Genre.all // Reset genre
        await fetchMoviesByGenreOrPopular()
    }

    func fetchNextPage() async {
        guard !isFetchingNextPage, !isLoading, currentPage < totalPages else { return }
        isFetchingNextPage = true
        currentPage += 1
        
        do {
            let response: MovieListResponseDTO
            if let searchQuery = currentSearchQuery, !searchQuery.isEmpty {
                response = try await tmdbService.searchMovies(query: searchQuery, page: currentPage)
            } else if selectedGenre.id != Genre.all.id {
                response = try await tmdbService.discoverMovies(genreId: selectedGenre.id, page: currentPage)
            } else {
                response = try await tmdbService.discoverMovies(genreId: nil, page: currentPage) // Or fetchPopularMovies
            }
            
            let incomingDtos = response.results
            let existingMovieIDs = Set(self.movies.map { $0.id })
            let newUniqueMoviesDTOs = incomingDtos.filter { !existingMovieIDs.contains($0.id) }
            let newMovies = updateFavoriteStatusOnFetched(movies: newUniqueMoviesDTOs.map { Movie(dto: $0) })
            
            if !newMovies.isEmpty {
                self.movies.append(contentsOf: newMovies)
            }
            self.totalPages = response.totalPages
        } catch {
            print("Failed to fetch next page: \(error.localizedDescription)")
            currentPage -= 1
        }
        isFetchingNextPage = false
    }

    // Method to toggle favorite status from MovieCardView
    func toggleFavorite(movie: Movie) {
        if favoriteService.isFavorite(movieId: movie.id) {
            favoriteService.removeFavorite(movieId: movie.id)
        } else {
            favoriteService.addFavorite(movie: movie)
        }
    }
} 
 
