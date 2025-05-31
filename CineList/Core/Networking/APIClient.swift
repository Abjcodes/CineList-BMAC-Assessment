import Foundation

// Custom network errors
enum NetworkError: Error {
    case badURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case serverError(statusCode: Int, data: Data?)
    case unknown
}

// Generic API client to handle requests and responses
class APIClient: APIClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        let urlRequest: URLRequest
        do {
            urlRequest = try endpoint.asURLRequest()
        } catch {
            throw NetworkError.badURL
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                 throw NetworkError.serverError(statusCode: httpResponse.statusCode, data: data)
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                // print("Decoding Error: \(error)") // Optional: for debugging
                throw NetworkError.decodingFailed(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error) 
        }
    }
} 
