import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MovieFeedView()
                .tabItem {
                    Label("Movies", systemImage: "film.stack")
                }
                .tag(0)

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(1)
        }
    }
}

#Preview {
    MainTabView()
} 