import Foundation
import CoreLocation

@MainActor
class GeocodingService: ObservableObject {
    private let geocoder = CLGeocoder()
    @Published var searchResults: [Location] = []
    @Published var isSearching = false
    @Published var error: Error?
    
    func searchLocations(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        defer { isSearching = false }
        
        do {
            let placemarks = try await geocoder.geocodeAddressString(query)
            searchResults = placemarks.compactMap { placemark in
                guard let name = placemark.name,
                      let location = placemark.location else { return nil }
                return Location(name: name, coordinate: location.coordinate)
            }
        } catch {
            self.error = error
            searchResults = []
        }
    }
} 