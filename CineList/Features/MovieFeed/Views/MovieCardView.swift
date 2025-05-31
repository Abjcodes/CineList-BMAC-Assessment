import SwiftUI


struct MovieCardView: View {
    let movie: Movie 
    var onFavoriteToggle: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                AsyncImageView(url: movie.posterURL) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(2/3, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.largeTitle)
                        )
                } imageConfiguration: { image -> Image in
                    image
                        .resizable()
                }
                .aspectRatio(2/3, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                Button(action: {
                    onFavoriteToggle() 
                }) {
                    if movie.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color.brandPrimary)
                            .padding(8)
                            .background(Circle().fill(Color.clear))
                    } else {
                        Image(systemName: "heart")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color.white)
                            .padding(8)
                            .background(Circle().fill(Color.black.opacity(0.4)))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(4)
                .shadow(color: Color.black.opacity(0.6), radius: 3, x: 0, y: 1)
                .accessibilityIdentifier("movieCard_favorite_button_\(movie.id)")
            }

            Text(movie.title)
                .font(.headline)
                .fontWeight(.medium)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("movieCard_title_text_\(movie.id)")

            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", movie.voteAverage))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .accessibilityIdentifier("movieCard_rating_stack_\(movie.id)")
            
            Spacer()
        }
        .padding(8)
    }
}

#Preview("Not Favorite") {
    var movie = Movie.example()
    movie.isFavorite = false
    return MovieCardView(movie: movie, onFavoriteToggle: {})
        .frame(width: 180)
}

#Preview("Is Favorite") {
    var movie = Movie.example()
    movie.isFavorite = true // Set favorite to true for this preview
    return MovieCardView(movie: movie, onFavoriteToggle: {})
        .frame(width: 180)
}

#Preview("Short Title - Not Favorite") {
    var movie: Movie {
        let dto = MovieDTO(
            adult: false, backdropPath: nil, genreIds: [], id: 124,
            originalLanguage: "en", originalTitle: "Short Film",
            overview: "A brief overview.", popularity: 6.5, posterPath: "/shortPoster.jpg",
            releaseDate: "2024-01-01", title: "Short Film",
            video: false, voteAverage: 7.2, voteCount: 50
        )
        var m = Movie(dto: dto)
        m.isFavorite = false
        return m
    }
    return MovieCardView(movie: movie, onFavoriteToggle: {})
        .frame(width: 180)
}

#Preview("Long Title - Is Favorite") {
     var movie: Movie {
        let dto = MovieDTO(
            adult: false, backdropPath: nil, genreIds: [], id: 123,
            originalLanguage: "en", originalTitle: "This is an Example of a Very Long Movie Title That Should Wrap Correctly",
            overview: "Overview here", popularity: 7.8, posterPath: "/longPoster.jpg",
            releaseDate: "2023-01-01", title: "This is an Example of a Very Long Movie Title That Should Wrap Correctly",
            video: false, voteAverage: 7.8, voteCount: 100
        )
        var m = Movie(dto: dto)
        m.isFavorite = true
        return m
    }
    return MovieCardView(movie: movie, onFavoriteToggle: {})
        .frame(width: 180)
}

#Preview("Movie with No Poster - Not Favorite") {
    var movie: Movie {
        let noPosterDTO = MovieDTO(
            adult: false, backdropPath: nil, genreIds: [], id: 125,
            originalLanguage: "en", originalTitle: "No Poster Movie",
            overview: "This movie has no poster.", popularity: 5.0, posterPath: nil,
            releaseDate: "2023-03-03", title: "No Poster Movie",
            video: false, voteAverage: 5.0, voteCount: 10
        )
        var m = Movie(dto: noPosterDTO)
        m.isFavorite = false
        return m
    }
    return MovieCardView(movie: movie, onFavoriteToggle: {})
        .frame(width: 180)
}

#if DEBUG
struct MovieCardView_Previews: PreviewProvider {
    static func previewMovie(isFavorite: Bool, id: Int = 278) -> Movie {
        let dto = MovieDTO(
            adult: false,
            backdropPath: "/kXfqcdQKsToO0OUXHcrrNCHDBzO.jpg",
            genreIds: [18, 80],
            id: id,
            originalLanguage: "en",
            originalTitle: "The Shawshank Redemption Preview",
            overview: "Preview overview.",
            popularity: 99,
            posterPath: "/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg",
            releaseDate: "1994-09-23",
            title: "The Shawshank Redemption (Preview)",
            video: false,
            voteAverage: 8.7,
            voteCount: 22000
        )
        var movie = Movie(dto: dto)
        movie.isFavorite = isFavorite
        return movie
    }

    static var previews: some View {
        Group {
            MovieCardView(movie: previewMovie(isFavorite: false), onFavoriteToggle: { print("Preview: Toggle fav (not fav)") })
                .frame(width: 180)
                .previewDisplayName("Not Favorite")

            MovieCardView(movie: previewMovie(isFavorite: true), onFavoriteToggle: { print("Preview: Toggle fav (is fav)") })
                .frame(width: 180)
                .previewDisplayName("Is Favorite")
        }
        .onAppear {
            // For testing previews with UserDefaults, you might clear it here
            // FavoriteService.shared.clearAllFavorites()
        }
    }
}
#endif 
