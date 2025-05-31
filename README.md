# CineList - Buy Me A Coffee Assessment
![Banner](https://github.com/user-attachments/assets/6627d985-d438-4004-b499-c394f1d5c236)

## Building and Running the Project

1.  **Prerequisites:**
    *   Xcode (latest stable version recommended, developed with Xcode 15.x)
    *   An active internet connection (for fetching movie data), offline states are handled in the app, and favorites will work as expected in offline mode because of UserDefaults. Rest are shown as cached.
    *   API key from [The Movie Database (TMDb)](https://www.themoviedb.org/settings/api) is already included in the project for easier execution (even though it's not a standard practice to share it through repo. This will be removed after the evaluation.)

2.  **Setup:**
    *   Clone the repository
    *   Open `CineList.xcodeproj` in Xcode.
    *   API key is already configured, this might change if github flags an issue. Please let me know if the key is not working.

3.  **Build & Run:**
    *   Select a target iOS Simulator or a connected iOS device in Xcode.
    *   Press the "Run" button 

## Architecture

CineList is built using **SwiftUI** and follows the **Model-View-ViewModel (MVVM)** architectural pattern.

*   **Model:** Represents the data and business logic (e.g., `Movie.swift`, `Genre.swift`). Data is sourced from the TMDb API and local storage (UserDefaults) for favorites.
*   **View:** The UI layer, built with SwiftUI (e.g., `MovieFeedView.swift`, `MovieDetailView.swift`).
*   **ViewModel:** Acts as an intermediary between the Model and the View (e.g., `MovieFeedViewModel.swift`). 

**Note: I've followed a feature first file structure for scalability.**

**Core Components:**
*   `Features/`: Contains modules for distinct app functionalities (MovieFeed, MovieDetails, Favorites).
*   `Core/`: Houses shared components:
    *   `Networking/`: Manages API communication with TMDb (e.g., `TMDBService.swift`, `APIClient.swift`).
    *   `Persistence/`: Handles local data storage (e.g., `FavoriteService.swift` using `UserDefaults`).
    *   `Models/`: Defines data structures (DTOs for API responses and domain models).
    *   `Utilities/`: Contains helper code, such as `BrandColor.swift` and Image Loaders.
