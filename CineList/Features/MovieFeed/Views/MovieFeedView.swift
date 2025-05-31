import SwiftUI

struct MovieFeedView: View {
    @StateObject private var viewModel = MovieFeedViewModel()
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search movies...", text: $viewModel.searchText) // Bind to viewModel.searchText
                        .textFieldStyle(PlainTextFieldStyle())
                        .accessibilityIdentifier("movieFeed_search_textField")
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = "" // Clear search text via ViewModel
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .accessibilityIdentifier("movieFeed_clearSearch_button")
                    }
                }
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
                // .padding(.bottom, 8) // Adjusted to be part of VStack spacing if needed

                // Genre Filter ScrollView
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.availableGenres) { genre in
                            Button(action: {
                                viewModel.selectedGenre = genre
                            }) {
                                Text(genre.name)
                                    .font(.system(size: 14, weight: viewModel.selectedGenre == genre ? .bold : .regular))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(viewModel.selectedGenre == genre ? Color.brandPrimary : Color.gray.opacity(0.2))
                                    .foregroundColor(viewModel.selectedGenre == genre ? .white : .primary)
                                    .cornerRadius(20)
                            }
                            .accessibilityIdentifier("movieFeed_genreButton_\(genre.name.replacingOccurrences(of: " ", with: "_"))")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12) // Padding for the genre bar itself
                }
                .background(Color(.systemBackground)) // Ensure it has a background, esp. in dark mode
                .accessibilityIdentifier("movieFeed_genreFilter_scrollView")
                // .padding(.bottom, 8) // Optional: space between genre bar and list

                // Content Area
                if viewModel.isLoading && viewModel.movies.isEmpty { 
                    ProgressView("Loading Movies...")
                        .frame(maxHeight: .infinity)
                        .accessibilityIdentifier("movieFeed_loading_progressView")
                } else if viewModel.errorMessage != nil { // Check if an error message exists
                    VStack(spacing: 15) {
                        Image(systemName: "exclamationmark.triangle.fill") // Example icon
                            .font(.system(size: 50))
                            .foregroundColor(Color.orange) // Warning color for the icon
                        
                        Text("Oops! Something went wrong.")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("We couldn\'t load the movies. Please check your connection and try again.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)

                        Button(action: {
                            Task {
                                if let currentQuery = viewModel.currentSearchQuery, !currentQuery.isEmpty {
                                    await viewModel.fetchMoviesByGenreOrPopular(isSearchTriggeredByTextChange: true)
                                } else {
                                    await viewModel.fetchMoviesByGenreOrPopular()
                                }
                            }
                        }) {
                            Text("Retry")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 30)
                                .background(Color.brandPrimary)
                                .cornerRadius(10)
                        }
                        .accessibilityIdentifier("movieFeed_retry_button")
                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                    .accessibilityIdentifier("movieFeed_errorView_stack") // Identifier for the whole error view
                } else if viewModel.movies.isEmpty && !viewModel.searchText.isEmpty && !viewModel.isLoading {
                     Text("No movies found for \"\(viewModel.searchText)\".")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxHeight: .infinity)
                        .accessibilityIdentifier("movieFeed_noSearchResults_text")
                } else if viewModel.movies.isEmpty && viewModel.searchText.isEmpty && !viewModel.isLoading {
                     Text("No movies found for \(viewModel.selectedGenre.name). Try another genre.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxHeight: .infinity)
                        .accessibilityIdentifier("movieFeed_noMoviesForGenre_text")
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.movies) { movie in
                                NavigationLink(destination: MovieDetailView(movie: movie)) {
                                    MovieCardView(movie: movie, onFavoriteToggle: {
                                        viewModel.toggleFavorite(movie: movie)
                                    })
                                }
                                .buttonStyle(PlainButtonStyle())
                                .accessibilityIdentifier("movieFeed_movieCard_navigationLink_\(movie.id)")
                                .onAppear {
                                    if movie.id == viewModel.movies.last?.id && !viewModel.isLoading {
                                        Task {
                                            await viewModel.fetchNextPage()
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        if viewModel.isFetchingNextPage { // Use a specific flag for pagination loading
                            ProgressView()
                                .padding()
                                .accessibilityIdentifier("movieFeed_nextPage_progressView")
                        }
                    }
                    .accessibilityIdentifier("movieFeed_movieList_scrollView")
                }
            }
            .navigationBarTitle("Movies")
            .navigationBarTitleDisplayMode(.automatic)
            .onAppear {
                if viewModel.movies.isEmpty && viewModel.searchText.isEmpty && viewModel.selectedGenre == Genre.all {
                    Task {
                        await viewModel.fetchInitialMovies()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
struct MovieFeedView_Previews: PreviewProvider {
    static var previews: some View {
        MovieFeedView()
    }
}
#endif 
 
