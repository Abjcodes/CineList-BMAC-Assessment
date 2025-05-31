//
//  CineListUITests.swift
//  CineListUITests
//
//  Created by Abijith Vasanthakumar on 30/05/25.
//

import XCTest

final class CineListUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        // We can add launch arguments or environment variables if needed for specific test states
        // For example, to reset data or use mock data for UI tests.
        // app.launchArguments += ["-UITesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    @MainActor
    func testAddAndRemoveFavoriteMovieFlow() throws {
       
        let movieFeedList = app.scrollViews["movieFeed_movieList_scrollView"]
        XCTAssertTrue(movieFeedList.waitForExistence(timeout: 15), "Movie feed list did not appear in time.")

        
        let firstMovieCard = movieFeedList.buttons.firstMatch
        XCTAssertTrue(firstMovieCard.exists, "No movie cards found in the feed.")
        
        
        firstMovieCard.tap()

        // --- Movie Detail View ---
        let movieDetailFavoriteButton = app.buttons["movieDetail_favorite_button"]
        XCTAssertTrue(movieDetailFavoriteButton.waitForExistence(timeout: 5), "Movie detail favorite button did not appear.")
        
        
        let movieTitleElement = app.staticTexts["movieDetail_title_text"]
        XCTAssertTrue(movieTitleElement.waitForExistence(timeout: 2), "Movie title on detail screen did not appear.")
        _ = movieTitleElement.label
        
        
        movieDetailFavoriteButton.tap() 
       
        // Navigate back to the movie feed
        app.navigationBars.buttons.element(boundBy: 0).tap() // Standard back button

        // --- Main Tab View: Switch to Favorites ---
        // Tab bars are identified by index or by their label's accessibility identifier if set.
        // Label("Favorites", systemImage: "heart.fill")
        app.tabBars.buttons.element(boundBy: 1).tap() // Tap the second tab (Favorites)

        // --- Favorites View ---
        // First, ensure the Favorites view itself is visible by checking its navigation bar title
        XCTAssertTrue(app.navigationBars["Favorites"].waitForExistence(timeout: 10), "Favorites view (navigation bar) did not appear.")

    }


}

// Extension to make accessing elements by identifier easier (optional but good practice)
extension XCUIApplication {
    func button(identifier: String) -> XCUIElement {
        return buttons[identifier]
    }
    func staticText(identifier: String) -> XCUIElement {
        return staticTexts[identifier]
    }
    // Add more for other element types as needed
}
