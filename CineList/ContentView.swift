//
//  ContentView.swift
//  CineList
//
//  Created by Abijith Vasanthakumar on 30/05/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MovieFeedView()
                .tabItem {
                    Label("Movies", systemImage: "film.stack")
                }
                .accessibilityIdentifier("contentView_movies_tab")
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .accessibilityIdentifier("contentView_favorites_tab")
            
            // You can add more tabs here if needed, e.g., for Settings
            // SettingsView()
            //     .tabItem {
            //         Label("Settings", systemImage: "gear")
            //     }
        }
        // Optional: Apply an accent color to the TabView for selected items
        // .accentColor(.blue) // Or your app's primary color
    }
}

#if DEBUG // Ensure Preview is only compiled in DEBUG builds
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
