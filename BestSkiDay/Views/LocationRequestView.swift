import SwiftUI
import CoreLocation
import CoreLocationUI

struct LocationRequestView: View {
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Location Access Required")
                .font(.title2)
                .bold()
            
            Text("To find the best ski day, we need access to your location to check nearby weather conditions.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            if let error = locationManager.lastError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            LocationButton(.shareCurrentLocation) {
                print("Location button tapped")
                locationManager.requestLocation()
            }
            .foregroundColor(.white)
            .cornerRadius(10)
            .labelStyle(.titleAndIcon)
            .padding(.horizontal)
        }
        .padding()
    }
} 