import Foundation
import CoreLocation

struct Location: Codable, Identifiable {
    let id: UUID
    let latitude: Double
    let longitude: Double
    let name: String
    
    init(name: String, coordinate: CLLocationCoordinate2D) {
        self.id = UUID()
        self.name = name
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case latitude
        case longitude
        case name
    }
} 