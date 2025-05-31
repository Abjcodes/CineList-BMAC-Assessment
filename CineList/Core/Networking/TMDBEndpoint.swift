import Foundation


enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
    func asURLRequest() throws -> URLRequest
}

extension Endpoint {
    var baseURL: String {
        return APIConstants.baseURL
    }

    var headers: [String: String]? {
        return [
            "Authorization": "Bearer \(APIConstants.readAccessToken)",
            "accept": "application/json"
        ]
    }

    var parameters: [String: Any]? {
        return nil // Default to no parameters.
    }

    func asURLRequest() throws -> URLRequest {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }
        urlComponents.path = path

        if method == .get, let parameters = parameters {
            urlComponents.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }

        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers

        if method != .get, let parameters = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        return request
    }
}


enum TMDBEndpoint {
    case popularMovies(page: Int)
    case movieDetails(id: Int)
    case searchMovies(query: String, page: Int)
    case movieGenres
    case discoverMovies(genreId: Int?, page: Int)
}

extension TMDBEndpoint: Endpoint {
    var path: String {
        switch self {
        case .popularMovies:
            return "/3/movie/popular"
        case .movieDetails(let id):
            return "/3/movie/\(id)"
        case .searchMovies:
            return "/3/search/movie"
        case .movieGenres:
            return "/3/genre/movie/list"
        case .discoverMovies:
            return "/3/discover/movie"
        }
    }

    var method: HTTPMethod {
        return .get
    }

    var parameters: [String: Any]? {
        var params: [String: Any] = [:]

        switch self {
        case .popularMovies(let page):
            params["page"] = page
            params["language"] = "en-US"
        case .movieDetails:
            params["language"] = "en-US"
        case .searchMovies(let query, let page):
            params["query"] = query
            params["page"] = page
            params["language"] = "en-US"
            params["include_adult"] = false
        case .movieGenres:
            params["language"] = "en" // Specifically for genres, as per TMDB docs for genre names
        case .discoverMovies(let genreId, let page):
            params["page"] = page
            params["sort_by"] = "popularity.desc"
            if let genreId = genreId, genreId != 0 { // genreId 0 is our local "All Genres"
                params["with_genres"] = "\(genreId)"
            }
            params["include_adult"] = false
        }
        return params.isEmpty ? nil : params
    }
} 
