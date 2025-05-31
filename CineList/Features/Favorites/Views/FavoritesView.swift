import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    
    // State for managing the confirmation alert
    @State private var showingRemoveConfirmationAlert = false
    @State private var movieToRemove: Movie? = nil

    // Define the grid layout, similar to MovieFeedView for consistency
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) { // Use spacing 0 if search bar is directly above list
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search favorites...", text: $viewModel.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .autocorrectionDisabled(true) // Optional: disable autocorrection for search
                        .accessibilityIdentifier("favorites_search_textField")
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .accessibilityIdentifier("favorites_clearSearch_button")
                    }
                }
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top) // Add padding above search bar
                .padding(.bottom, 8) // Space between search bar and content

                // Content Area
                if viewModel.isLoading {
                    ProgressView("Loading Favorites...")
                        .frame(maxHeight: .infinity)
                        .accessibilityIdentifier("favorites_loading_progressView")
                } else if viewModel.filteredMovies.isEmpty {
                    if !viewModel.searchText.isEmpty {
                        Text("No favorite movies found for \"\(viewModel.searchText)\".")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxHeight: .infinity)
                            .accessibilityIdentifier("favorites_noSearchResults_text")
                    } else if let errorMessage = viewModel.currentErrorMessage {
                        Text(errorMessage) // e.g., "You haven't added any movies to your favorites yet."
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxHeight: .infinity)
                            .accessibilityIdentifier("favorites_errorMessage_text")
                    } else {
                        // Fallback for empty state if no error message but still no movies (should be covered by above)
                        Text("No favorite movies yet. Add some from the main feed!")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxHeight: .infinity)
                            .accessibilityIdentifier("favorites_noFavoritesYet_text")
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.filteredMovies) { movie in // Iterate over filteredMovies
                                NavigationLink(destination: MovieDetailView(movie: movie)) {
                                    MovieCardView(movie: movie, onFavoriteToggle: {
                                        // Instead of direct toggle, prepare for alert
                                        self.movieToRemove = movie 
                                        self.showingRemoveConfirmationAlert = true
                                    })
                                }
                                .buttonStyle(PlainButtonStyle())
                                .accessibilityIdentifier("favorites_movieCard_navigationLink_\(movie.id)")
                            }
                        }
                        .padding() // Apply padding to the LazyVGrid's content
                    }
                    .accessibilityIdentifier("favorites_movieList_scrollView")
                }
            }
            .navigationTitle("Favorites")
            .onAppear {
                viewModel.onAppear() // Load favorites when the view appears
            }
            .alert(isPresented: $showingRemoveConfirmationAlert) {
                Alert(
                    title: Text("Remove Favorite"),
                    message: Text("Are you sure you want to remove \"\(movieToRemove?.title ?? "this movie")\" from your favorites?"),
                    primaryButton: .destructive(Text("Remove")) {
                        if let movie = movieToRemove {
                            viewModel.toggleFavorite(movie: movie) // This will remove it
                        }
                        movieToRemove = nil // Reset
                    },
                    secondaryButton: .cancel() {
                        movieToRemove = nil // Reset
                    }
                )
            }
            .accessibilityIdentifier("favorites_view")
            // Optional: Add a refresh control if desired later
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Consistent navigation style
    }
}

#if DEBUG
struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        // Mocking FavoriteService for previews can be complex.
        // For a start, let's ensure it compiles and shows an empty state or basic state.
        
        // To preview with items, you'd need to:
        // 1. Ensure FavoriteService.shared can be mocked or pre-populated for previews.
        // 2. Or, inject a mock service into FavoritesViewModel for the preview.

        // Example: If FavoriteService could be cleared and populated for preview scope:
        // let service = FavoriteService.shared
        // service.clearAllFavorites() // Clear first
        // service.addFavorite(movie: Movie.example()) // Add a dummy movie
        
        FavoritesView()
    }
}
#endif 