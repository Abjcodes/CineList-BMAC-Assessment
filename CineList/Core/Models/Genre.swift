import Foundation

struct Genre: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String

    init(dto: GenreDTO) {
        self.id = dto.id
        self.name = dto.name
    }
    
    static let all = Genre(id: 0, name: "All Genres")
    
    private init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
} 
