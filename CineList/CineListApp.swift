//
//  CineListApp.swift
//  CineList
//
//  Created by Abijith Vasanthakumar on 30/05/25.
//

import SwiftUI

@main
struct CineListApp: App {
    @State private var isActive: Bool = false

    // init() {
        // TMDBService.fetchAndPrintPopularMovies() // Example initial call, consider moving to a ViewModel or onAppear
    // }

    var body: some Scene {
        WindowGroup {
            if isActive {
                MainTabView()
                    .accentColor(Color.brandPrimary)
            } else {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { // Splash screen duration
                            withAnimation {
                                self.isActive = true
                            }
                        }
                    }
            }
        }
    }
}
