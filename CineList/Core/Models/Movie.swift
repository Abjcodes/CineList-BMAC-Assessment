import Foundation

struct Movie: Identifiable, Equatable, Hashable, Codable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: Date?
    let voteAverage: Double
    let posterPath: String?
    var backdropPath: String?
    var isFavorite: Bool = false // Updated from local storage

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case releaseDate
        case voteAverage
        case posterPath
        case backdropPath
        case isFavorite
    }

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "\(APIConstants.imageBaseURL)w500\(path)")
    }

    var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: "\(APIConstants.imageBaseURL)w780\(path)")
    }

    init(dto: MovieDTO) {
        self.id = dto.id
        self.title = dto.title ?? "N/A"
        self.overview = dto.overview ?? "No overview available."
        self.voteAverage = dto.voteAverage ?? 0.0
        self.posterPath = dto.posterPath
        self.backdropPath = dto.backdropPath
        
        if let dateString = dto.releaseDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.releaseDate = dateFormatter.date(from: dateString)
        } else {
            self.releaseDate = nil
        }
    }
    
    static func example() -> Movie {
        let dummyDTO = MovieDTO(
            adult: false,
            backdropPath: "/kXfqcdQKsToO0OUXHcrrNCHDBzO.jpg",
            genreIds: [18, 80],
            id: 278,
            originalLanguage: "en",
            originalTitle: "The Shawshank Redemption",
            overview: "Framed in the 1940s for the double murder of his wife and her lover, upstanding banker Andy Dufresne begins a new life at the Shawshank prison, where he puts his accounting skills to work for an amoral warden. During his long stretch in prison, Dufresne comes to be admired by the other inmates -- including an older prisoner named Red -- for his integrity and unquenchable sense of hope.",
            popularity: 99,
            posterPath: "/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg",
            releaseDate: "1994-09-23",
            title: "The Shawshank Redemption",
            video: false,
            voteAverage: 8.7,
            voteCount: 22000
        )
        return Movie(dto: dummyDTO)
    }
} 
