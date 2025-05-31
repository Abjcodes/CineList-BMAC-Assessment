import Foundation
@testable import CineList // Import your app module to access its types

class MockAPIClient: APIClientProtocol {
    var result: Result<Any, NetworkError>?

    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        guard let result = result else {
            fatalError("MockAPIClient.result not set. Provide a Result to return.")
        }

        switch result {
        case .success(let data):
            if let typedData = data as? T {
                return typedData
            } else {
                // If data is Data, try to decode it. This is common for JSON responses.
                if let jsonData = data as? Data {
                    do {
                        let decoder = JSONDecoder()
                        return try decoder.decode(T.self, from: jsonData)
                    } catch {
                        print("MockAPIClient decoding error: \(error)")
                        throw NetworkError.decodingFailed(error)
                    }
                } else {
                    fatalError("MockAPIClient result type mismatch. Expected \(T.self), got \(type(of: data))")
                }
            }
        case .failure(let error):
            throw error
        }
    }
    
    // Helper to set successful result with Encodable data (like DTOs)
    func setSuccess<E: Encodable>(with encodableData: E) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(encodableData)
            self.result = .success(data as Any) // Store as Data to be decoded by request<T>
        } catch {
            fatalError("MockAPIClient: Failed to encode provided data: \(error)")
        }
    }

    // Helper to set failure result
    func setFailure(with error: NetworkError) {
        self.result = .failure(error)
    }
} 