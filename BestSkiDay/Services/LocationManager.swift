import CoreLocation

class LocationManager: NSObject, ObservableObject {
    @Published var currentLocation: Location?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastError: String?
    
    private let manager: CLLocationManager
    
    override init() {
        manager = CLLocationManager()
        authorizationStatus = manager.authorizationStatus
        
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        print("LocationManager initialized with status: \(manager.authorizationStatus.rawValue)")
    }
    
    func requestLocation() {
        print("Requesting location...")
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("Authorization changed to: \(manager.authorizationStatus.rawValue)")
            self.authorizationStatus = manager.authorizationStatus
            
            if manager.authorizationStatus == .authorizedWhenInUse {
                print("Requesting location after authorization")
                self.manager.requestLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { 
            print("No location received")
            return 
        }
        print("Location received: \(location.coordinate)")
        
        DispatchQueue.main.async { [weak self] in
            self?.currentLocation = Location(
                name: "Current Location",
                coordinate: location.coordinate
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
            self?.lastError = error.localizedDescription
        }
    }
} 