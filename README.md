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
  
4. **Testing**
   *    To set dark mode in simulator: Setting -> Developer -> Dark Appearance

## Architecture

CineList is built using **SwiftUI** and **Combine** and follows the **Model-View-ViewModel (MVVM)** architectural pattern.

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

## Additional Features Implemented
* Splash screen to match standard IOS user experience
* Genre based filters - An additional API call but much more convenient for the users to find movies
* Caching
* Dark mode + Light mode support
* Debouce based search
* Errors states and screens
* App assets - Logo designed using ChatGPT imagegen, may throw minor warnings for iPad targets

## Design Decisions
* The favorite icon is implemented in both MovieFeedView and MovieDetailScreen to ensure accessibility, since the image can determine how it appears on the screen. A custom back button is integrated in the details screen for the same reason.
* Genre based filters are shown just below search bar so that it's easy for the user to notice.
* The layout is responsive and is tested in both iphone SE and iphone 16 Pro.
* The movie title is set to two line limit, proceeded with truncation, to make it suitable for UI scaling
* App is designed to be consistent in both dark and light mode. (PS: I like dark mode better).
* Favourite button is added directly in movie card, so that it makes it easier for the user to add it directly to the list
* The user will be alerted if they are trying to remove favourite movie in favourite tab, this is to prevent accidental touches. The same is not implemented in the moviefeed view since the main usecase of that screen is searching and discovering movies.
 
## Screenshots

### Light Mode (iPhone SE)

<div align="center">
   <img src="https://github.com/user-attachments/assets/a104248e-a5b3-4eab-a02a-08778ef6b537" width="150"/>
  <img src="https://github.com/user-attachments/assets/fd5e2ff9-1c96-4775-acbc-098b93c70bf8" width="150"/>
  <img src="https://github.com/user-attachments/assets/fb757715-27b3-421f-bec3-946d4c4863fd" width="150"/>
  <img src="https://github.com/user-attachments/assets/622d9210-9d5f-4032-857d-5170362bf7aa" width="150"/>
  <img src="https://github.com/user-attachments/assets/fd6678b1-2f59-48b7-9ea4-565a93919b70" width="150"/>
  <img src="https://github.com/user-attachments/assets/a3ad2d0c-2c15-49cd-ad68-c0cc6f1c2dfd" width="150"/>
</div>

---

### Dark Mode (iPhone 16 Pro)

<div align="center">
  <img src="https://github.com/user-attachments/assets/5c5dd7f4-834a-4d5c-8617-093e4235e780" width="150"/>
  <img src="https://github.com/user-attachments/assets/ddefcbef-4208-4b45-976a-37da2ab828ea" width="150"/>
  <img src="https://github.com/user-attachments/assets/db7abe12-9818-4b56-8b51-6e6c9456d40d" width="150"/>
  <img src="https://github.com/user-attachments/assets/bf304f11-1a90-4636-937c-52e88920b124" width="150"/>
  <img src="https://github.com/user-attachments/assets/7f79700c-ea33-462a-bd60-b4a17faca739" width="150"/>
  <img src="https://github.com/user-attachments/assets/39435561-6610-46c9-b7ee-1e6a6cc141d9" width="150"/>
</div>


## What can be improved?
* Offline support changes - Implement a network monitor and notify the user if the app is offline, through UI. Currently the app will work fine with cached responses and UserDefaults.
* More info in details screen
* Implement animations, eg: Text animation for movie title in MovieFeedView if it's truncated. So that user can see the full movie title without entering detail screen.
* Add notes to the saved movies
* Improved test coverage, currently the app is at 80%
* Implement scrolling enhancements in UI











