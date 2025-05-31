import SwiftUI
import Combine

struct MovieDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // StateObject to keep the ViewModel alive for the view's lifecycle
    @StateObject private var viewModel: MovieDetailViewModel

    // Initializer to receive the movie and create the ViewModel
    init(movie: Movie) {
        _viewModel = StateObject(wrappedValue: MovieDetailViewModel(movie: movie))
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .bottom) {
                        // Backdrop Image
                        if let backdropURL = viewModel.movie.backdropURL {
                            AsyncImageView(url: backdropURL, placeholder: {
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: geometry.size.height * 0.6)
                                    .background(Color.gray.opacity(0.3))
                            })
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
                            .clipped()
                            .accessibilityIdentifier("movieDetail_backdrop_image")
                        } else if let posterURL = viewModel.movie.posterURL { // Fallback to poster
                             AsyncImageView(url: posterURL, placeholder: {
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: geometry.size.height * 0.6)
                                    .background(Color.gray.opacity(0.3))
                             })
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
                            .clipped()
                            .accessibilityIdentifier("movieDetail_poster_image")
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
                                .overlay(
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.gray)
                                )
                                .accessibilityIdentifier("movieDetail_placeholder_image")
                        }

                        // Gradient Overlay
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color(.systemBackground)]),
                            startPoint: .init(x: 0.5, y: 0.4),
                            endPoint: .bottom
                        )
                        .frame(height: 200)
                    }

                    // Title
                    Text(viewModel.movie.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .accessibilityIdentifier("movieDetail_title_text")

                    // HStack for Release Date and Rating
                    HStack(spacing: 16) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(viewModel.movie.voteAverage, specifier: "%.1f")/10")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityIdentifier("movieDetail_rating_stack")

                        if let releaseDate = viewModel.movie.releaseDate {
                            HStack {
                                Image(systemName: "calendar")
                                Text("\(releaseDate, style: .date)")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .accessibilityIdentifier("movieDetail_releaseDate_stack")
                        }
                        
                        Spacer() // Pushes content to the left if needed
                    }
                    .padding(.horizontal)
                    .padding(.top, 8) // Space between title and this HStack

                    // Overview
                    Text(viewModel.movie.overview)
                        .font(.body)
                        .padding(.horizontal)
                        .padding(.top, 16) // Increased top padding for separation
                        .accessibilityIdentifier("movieDetail_overview_text")
                    
                    Spacer()                        .padding(.bottom, 16) 
                }
            }
            .accessibilityIdentifier("movieDetail_scrollView")
            .ignoresSafeArea(.container, edges: .top)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: 
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(Color.white)
                            .padding(8)
                            .background(Circle().fill(Color.black.opacity(0.4)))
                            .clipShape(Circle())
                    }
                    .imageScale(.large)
                    .accessibilityIdentifier("movieDetail_customBackButton"),
                trailing: 
                    Button(action: {
                        viewModel.toggleFavorite()
                    }) {
                        // Apply similar styling logic as in MovieCardView for consistency
                        if viewModel.isFavorite {
                            Image(systemName: "heart.fill")
                                .foregroundColor(Color.brandPrimary)
                        } else {
                            Image(systemName: "heart")
                                .foregroundColor(Color.white)
                                .padding(8)
                                .background(Circle().fill(Color.black.opacity(0.4))) 
                                .clipShape(Circle())
                        }
                    }
                    .imageScale(.large)
                    .accessibilityIdentifier("movieDetail_favorite_button")
            )
        }
    }
}

#if DEBUG
struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Example movie for preview
        let exampleMovieDTO = MovieDTO(
            adult: false,
            backdropPath: "/kXfqcdQKsToO0OUXHcrrNCHDBzO.jpg",
            genreIds: [18, 80],
            id: 278,
            originalLanguage: "en",
            originalTitle: "The Shawshank Redemption",
            overview: "Framed in the 1940s for the double murder of his wife and her lover, upstanding banker Andy Dufresne begins a new life at the Shawshank prison...",
            popularity: 99,
            posterPath: "/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg",
            releaseDate: "1994-09-23",
            title: "The Shawshank Redemption",
            video: false,
            voteAverage: 8.7,
            voteCount: 22000
        )
        let movie = Movie(dto: exampleMovieDTO)

        NavigationView {
            MovieDetailView(movie: movie)
        }
        .preferredColorScheme(.dark)
        
        NavigationView {
            MovieDetailView(movie: movie) // Re-use the same movie instance for light mode
        }
        .preferredColorScheme(.light)
        
        // Preview with no backdrop/poster and favorited
        NavigationView {
             MovieDetailView(movie: {
                let noImageDTO = MovieDTO(
                    adult: false, backdropPath: nil, genreIds: [], id: 279,
                    originalLanguage: "en", originalTitle: "No Images Movie",
                    overview: "Test overview.", popularity: 5.0, posterPath: nil,
                    releaseDate: "2023-01-01", title: "No Images & Favorited",
                    video: false, voteAverage: 6.5, voteCount: 100
                )
                var noImageMovie = Movie(dto: noImageDTO)
                noImageMovie.isFavorite = true // Set to favorite for this preview
                return noImageMovie
            }())
        }
        .preferredColorScheme(.dark)
    }
}
#endif 
