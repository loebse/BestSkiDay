import Foundation

@MainActor
class FavoriteLocationsManager: ObservableObject {
    @Published private(set) var favorites: [Location] = []
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favoriteLocations"
    
    init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        if let data = userDefaults.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([Location].self, from: data) {
            favorites = decoded
        }
    }
    
    func addFavorite(_ location: Location) {
        guard !favorites.contains(where: { $0.id == location.id }) else { return }
        favorites.append(location)
        saveFavorites()
    }
    
    func removeFavorite(_ location: Location) {
        favorites.removeAll { $0.id == location.id }
        saveFavorites()
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            userDefaults.set(encoded, forKey: favoritesKey)
        }
    }
} 