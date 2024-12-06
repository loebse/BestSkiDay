//
//  ContentView.swift
//  BestSkiDay
//
//  Created by Sebastian on 06.12.24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherService = WeatherService()
    
    var body: some View {
        NavigationView {
            VStack {
                switch locationManager.authorizationStatus {
                case .notDetermined, .restricted, .denied:
                    LocationRequestView(locationManager: locationManager)
                case .authorizedWhenInUse, .authorizedAlways:
                    if let location = locationManager.currentLocation {
                        WeatherForecastView(location: location)
                            .environmentObject(weatherService)
                    } else {
                        ProgressView("Getting location...")
                    }
                @unknown default:
                    Text("Unexpected authorization status")
                }
            }
            .navigationTitle("Best Ski Day")
        }
    }
}

#Preview {
    ContentView()
}
