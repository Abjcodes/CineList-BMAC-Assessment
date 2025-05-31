import Foundation

// Protocol for TMDBService, primarily for mocking in tests.
protocol TMDBServiceProtocol {
    func fetchPopularMovies(page: Int) async throws -> MovieListResponseDTO
    func fetchMovieDetails(id: Int) async throws -> MovieDTO
    func searchMovies(query: String, page: Int) async throws -> MovieListResponseDTO
    func fetchMovieGenres() async throws -> GenreListResponseDTO
    func discoverMovies(genreId: Int?, page: Int) async throws -> MovieListResponseDTO
}

class TMDBService: TMDBServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchPopularMovies(page: Int = 1) async throws -> MovieListResponseDTO {
        let endpoint = TMDBEndpoint.popularMovies(page: page)
        return try await apiClient.request(endpoint: endpoint)
    }

    func fetchMovieDetails(id: Int) async throws -> MovieDTO {
        let endpoint = TMDBEndpoint.movieDetails(id: id)
        return try await apiClient.request(endpoint: endpoint)
    }

    func searchMovies(query: String, page: Int = 1) async throws -> MovieListResponseDTO {
        let endpoint = TMDBEndpoint.searchMovies(query: query, page: page)
        return try await apiClient.request(endpoint: endpoint)
    }

    func fetchMovieGenres() async throws -> GenreListResponseDTO {
        let endpoint = TMDBEndpoint.movieGenres
        return try await apiClient.request(endpoint: endpoint)
    }

    func discoverMovies(genreId: Int?, page: Int) async throws -> MovieListResponseDTO {
        let endpoint = TMDBEndpoint.discoverMovies(genreId: genreId, page: page)
        return try await apiClient.request(endpoint: endpoint)
    }
    
    // Can be removed or moved (e.g., to a debug utility or test suite).
    static func fetchAndPrintPopularMovies() {
        Task {
            let service = TMDBService()
            do {
                _ = try await service.fetchPopularMovies(page: 1)
               
            } catch let error as NetworkError {
                switch error {
                case .badURL:
                    print("Static Test Fetch Error: Bad URL")
                case .requestFailed(let underlyingError):
                    print("Static Test Fetch Error: Request Failed - \(underlyingError.localizedDescription)")
                case .invalidResponse:
                    print("Static Test Fetch Error: Invalid Response")
                case .decodingFailed(let underlyingError):
                    print("Static Test Fetch Error: Decoding Failed - \(underlyingError.localizedDescription)")
                    // Detailed decoding error breakdown is useful for debugging here.
                    if let decodingError = underlyingError as? DecodingError {
                        switch decodingError {
                        case .typeMismatch(let type, let context): print("  Type mismatch: \(type), context: \(context.debugDescription)")
                        case .valueNotFound(let type, let context): print("  Value not found: \(type), context: \(context.debugDescription)")
                        case .keyNotFound(let key, let context): print("  Key not found: \(key), context: \(context.debugDescription)")
                        case .dataCorrupted(let context): print("  Data corrupted: \(context.debugDescription)")
                        @unknown default: print("  Unknown decoding error")
                        }
                    }
                case .serverError(statusCode: let statusCode, data: let data):
                    print("Static Test Fetch Error: Server Error - Status \(statusCode)")
                    if let data = data, let errorString = String(data: data, encoding: .utf8) {
                        print("  Server Response: \(errorString)")
                    }
                case .unknown:
                    print("Static Test Fetch Error: Unknown network error")
                }
            } catch {
                print("Static Test Fetch Error: An unexpected error occurred: \(error.localizedDescription)")
            }
        }
    }
} 
 
