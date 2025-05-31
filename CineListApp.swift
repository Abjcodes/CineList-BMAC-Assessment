//
//  CineListApp.swift
//  CineList
//
//  Created by Abijith Vasanthakumar on 30/05/25.
//

import SwiftUI

@main
struct CineListApp: App {
    init() {
        // TMDBService.fetchAndPrintPopularMovies() // We will move this to a ViewModel
    }

    var body: some Scene {
        WindowGroup {
            MainTabView() // Use MainTabView as the root view
        }
    }
} 