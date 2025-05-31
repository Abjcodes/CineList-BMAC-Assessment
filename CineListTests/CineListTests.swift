//
//  CineListTests.swift
//  CineListTests
//
//  Created by Abijith Vasanthakumar on 30/05/25.
//

import XCTest
@testable import CineList // Ensure your app module is imported

final class TMDBServiceTests: XCTestCase {

    var mockApiClient: MockAPIClient!
    var tmdbService: TMDBService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockApiClient = MockAPIClient()
        tmdbService = TMDBService(apiClient: mockApiClient)
    }

    override func tearDownWithError() throws {
        mockApiClient = nil
        tmdbService = nil
        try super.tearDownWithError()
    }

    // MARK: - Test fetchPopularMovies

    func testFetchPopularMovies_Success() async throws {
        // Arrange: Prepare mock response data
        let mockMovieDTO = MovieDTO(adult: false, backdropPath: "/path.jpg", genreIds: [1], id: 1, originalLanguage: "en", originalTitle: "Movie 1", overview: "Overview 1", popularity: 10.0, posterPath: "/poster.jpg", releaseDate: "2023-01-01", title: "Movie 1", video: false, voteAverage: 7.0, voteCount: 100)
        let mockResponse = MovieListResponseDTO(page: 1, results: [mockMovieDTO], totalPages: 1, totalResults: 1)
        mockApiClient.setSuccess(with: mockResponse)

        // Act: Call the service method
        do {
            let response = try await tmdbService.fetchPopularMovies(page: 1)
            // Assert: Check if the response is correctly parsed
            XCTAssertEqual(response.page, 1)
            XCTAssertEqual(response.results.count, 1)
            XCTAssertEqual(response.results.first?.id, mockMovieDTO.id)
            XCTAssertEqual(response.results.first?.title, mockMovieDTO.title)
        } catch {
            XCTFail("fetchPopularMovies should not throw an error on success: \(error)")
        }
    }

    func testFetchPopularMovies_Failure_DecodingError() async {
        // Arrange: Set up mock to return invalid data that causes decoding error
        // We simulate this by providing data that doesn't match MovieListResponseDTO structure
        let corruptData = Data("{\"invalid_json\": true}".utf8)
        mockApiClient.result = .success(corruptData as Any)
        
        // Act & Assert
        do {
            _ = try await tmdbService.fetchPopularMovies(page: 1)
            XCTFail("fetchPopularMovies should have thrown a decoding error")
        } catch let error as NetworkError {
            if case .decodingFailed = error {
                // Success, expected error
            } else {
                XCTFail("fetchPopularMovies threw an unexpected NetworkError type: \(error)")
            }
        } catch {
            XCTFail("fetchPopularMovies threw an unexpected error type: \(error)")
        }
    }
    
    func testFetchPopularMovies_Failure_ServerError() async {
        // Arrange
        mockApiClient.setFailure(with: .serverError(statusCode: 500, data: nil))
        
        // Act & Assert
        do {
            _ = try await tmdbService.fetchPopularMovies(page: 1)
            XCTFail("fetchPopularMovies should have thrown a server error")
        } catch NetworkError.serverError(let statusCode, _) {
            XCTAssertEqual(statusCode, 500)
        } catch {
            XCTFail("fetchPopularMovies threw an unexpected error type: \(error)")
        }
    }

    // MARK: - Test fetchMovieDetails
    func testFetchMovieDetails_Success() async throws {
        // Arrange
        let mockMovieDetailDTO = MovieDTO(adult: false, backdropPath: "/detail_path.jpg", genreIds: [2], id: 101, originalLanguage: "fr", originalTitle: "Le Film", overview: "Un bon film.", popularity: 100.0, posterPath: "/detail_poster.jpg", releaseDate: "2024-01-01", title: "The Movie", video: false, voteAverage: 8.5, voteCount: 1000)
        mockApiClient.setSuccess(with: mockMovieDetailDTO)

        // Act
        do {
            let response = try await tmdbService.fetchMovieDetails(id: 101)
            // Assert
            XCTAssertEqual(response.id, 101)
            XCTAssertEqual(response.title, "The Movie")
            XCTAssertEqual(response.overview, "Un bon film.")
        } catch {
            XCTFail("fetchMovieDetails should not throw an error on success: \(error)")
        }
    }

    func testFetchMovieDetails_Failure_RequestFailed() async {
        // Arrange
        mockApiClient.setFailure(with: .requestFailed(URLError(.notConnectedToInternet)))
        
        // Act & Assert
        do {
            _ = try await tmdbService.fetchMovieDetails(id: 101)
            XCTFail("fetchMovieDetails should have thrown a requestFailed error")
        } catch NetworkError.requestFailed(let underlyingError) {
            XCTAssertEqual((underlyingError as? URLError)?.code, URLError.notConnectedToInternet)
        } catch {
            XCTFail("fetchMovieDetails threw an unexpected error type: \(error)")
        }
    }
    
    // MARK: - Test searchMovies
    func testSearchMovies_Success() async throws {
        let mockMovieDTO1 = MovieDTO(adult: nil, backdropPath: nil, genreIds: nil, id: 1, originalLanguage: nil, originalTitle: nil, overview: nil, popularity: nil, posterPath: nil, releaseDate: nil, title: "Search Result 1", video: nil, voteAverage: nil, voteCount: nil)
        let mockMovieDTO2 = MovieDTO(adult: nil, backdropPath: nil, genreIds: nil, id: 2, originalLanguage: nil, originalTitle: nil, overview: nil, popularity: nil, posterPath: nil, releaseDate: nil, title: "Search Result 2", video: nil, voteAverage: nil, voteCount: nil)
        let mockResponse = MovieListResponseDTO(page: 1, results: [mockMovieDTO1, mockMovieDTO2], totalPages: 1, totalResults: 2)
        mockApiClient.setSuccess(with: mockResponse)
        
        let response = try await tmdbService.searchMovies(query: "Test Query", page: 1)
        
        XCTAssertEqual(response.results.count, 2)
        XCTAssertTrue(response.results.contains(where: { $0.id == 1 && $0.title == "Search Result 1" }))
        XCTAssertTrue(response.results.contains(where: { $0.id == 2 && $0.title == "Search Result 2" }))
    }

    // MARK: - Test fetchMovieGenres
    func testFetchMovieGenres_Success() async throws {
        let mockGenreDTO = GenreDTO(id: 28, name: "Action")
        let mockGenreResponse = GenreListResponseDTO(genres: [mockGenreDTO])
        mockApiClient.setSuccess(with: mockGenreResponse)

        let response = try await tmdbService.fetchMovieGenres()

        XCTAssertEqual(response.genres.count, 1)
        XCTAssertEqual(response.genres.first?.id, 28)
        XCTAssertEqual(response.genres.first?.name, "Action")
    }

    // MARK: - Test discoverMovies
    func testDiscoverMovies_Success_WithGenre() async throws {
        let mockMovieDTO = MovieDTO(adult: nil, backdropPath: nil, genreIds: [18], id: 3, originalLanguage: nil, originalTitle: nil, overview: nil, popularity: nil, posterPath: nil, releaseDate: nil, title: "Discovered Movie", video: nil, voteAverage: nil, voteCount: nil)
        let mockResponse = MovieListResponseDTO(page: 1, results: [mockMovieDTO], totalPages: 1, totalResults: 1)
        mockApiClient.setSuccess(with: mockResponse)

        let response = try await tmdbService.discoverMovies(genreId: 18, page: 1)

        XCTAssertEqual(response.results.count, 1)
        XCTAssertEqual(response.results.first?.id, 3)
        XCTAssertEqual(response.results.first?.genreIds?.contains(18), true)
    }
    
    func testDiscoverMovies_Success_WithoutGenre() async throws {
        let mockMovieDTO = MovieDTO(adult: nil, backdropPath: nil, genreIds: nil, id: 4, originalLanguage: nil, originalTitle: nil, overview: nil, popularity: nil, posterPath: nil, releaseDate: nil, title: "Discovered Popular Movie", video: nil, voteAverage: nil, voteCount: nil)
        let mockResponse = MovieListResponseDTO(page: 1, results: [mockMovieDTO], totalPages: 1, totalResults: 1)
        mockApiClient.setSuccess(with: mockResponse)

        let response = try await tmdbService.discoverMovies(genreId: nil, page: 1)

        XCTAssertEqual(response.results.count, 1)
        XCTAssertEqual(response.results.first?.id, 4)
    }
}
