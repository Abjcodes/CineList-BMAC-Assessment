import Foundation

// Protocol for APIClient, primarily to enable mocking for testing.
protocol APIClientProtocol {
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T
} 