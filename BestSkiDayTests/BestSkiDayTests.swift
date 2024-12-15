//
//  BestSkiDayTests.swift
//  BestSkiDayTests
//
//  Created by Sebastian on 06.12.24.
//

import Testing
import CoreLocation
@testable import BestSkiDay

struct BestSkiDayTests {
    
    // MARK: - WeatherForecast Tests
    
    @Test func testWeatherScoreCalculation() {
        let forecast = WeatherForecast(
            date: Date(),
            temperatureMin: -4,
            temperatureMax: 0,
            snowfall: 10,
            snowHeight: 50,
            sunshine: 80
        )
        
        // Score components:
        // Temperature: avg = -2°C (optimal) = 100 points * 0.3 = 30
        // Snow: (10cm * 10 + 50cm * 0.5) = 125, capped at 100 points * 0.4 = 40
        // Sunshine: 80% = 80 points * 0.3 = 24
        // Total expected: 94
        
        #expect(Int(forecast.score) == 94)
    }
    
    @Test func testSuboptimalConditionsScore() {
        let forecast = WeatherForecast(
            date: Date(),
            temperatureMin: 10,
            temperatureMax: 15,
            snowfall: 0,
            snowHeight: 10,
            sunshine: 20
        )
        
        // Score should be low due to high temperature, low snow, and low sunshine
        #expect(forecast.score < 60)
    }
    
    // MARK: - Location Tests
    
    @Test func testLocationEquality() {
        let coordinate = CLLocationCoordinate2D(latitude: 47.0, longitude: 10.0)
        let location1 = Location(name: "Test Resort", coordinate: coordinate)
        let location2 = Location(name: "Test Resort", coordinate: coordinate)
        
        // Different UUIDs should make them unequal
        #expect(location1.id != location2.id)
        #expect(location1.latitude == location2.latitude)
        #expect(location1.longitude == location2.longitude)
        #expect(location1.name == location2.name)
    }
    
    // MARK: - FavoriteLocationsManager Tests
    
    @MainActor
    @Test func testFavoriteLocationsManagement() {
        let manager = FavoriteLocationsManager()
        let location = Location(
            name: "Test Resort",
            coordinate: CLLocationCoordinate2D(latitude: 47.0, longitude: 10.0)
        )
        
        // Test adding favorite
        manager.addFavorite(location)
        #expect(manager.favorites.count == 1)
        #expect(manager.favorites.first?.name == "Test Resort")
        
        // Test duplicate prevention
        manager.addFavorite(location)
        #expect(manager.favorites.count == 1)
        
        // Test removal
        manager.removeFavorite(location)
        #expect(manager.favorites.isEmpty)
    }
    
    // MARK: - WeatherService Tests
    
    @MainActor
    @Test func testWeatherServiceURLConstruction() async {
        let service = WeatherService()
        let location = Location(
            name: "Test Resort",
            coordinate: CLLocationCoordinate2D(latitude: 47.0, longitude: 10.0)
        )
        
        // Fetch weather to trigger URL construction
        try? await service.fetchWeatherForecast(for: location)
        
        // The error should be nil if URL construction succeeded
        #expect(service.error == nil)
    }
    
    @MainActor
    @Test func testWeatherServiceErrorHandling() async {
        let service = WeatherService()
        let invalidLocation = Location(
            name: "Invalid",
            coordinate: CLLocationCoordinate2D(latitude: 1000, longitude: 1000)
        )
        
        // Fetch with invalid coordinates should result in error
        try? await service.fetchWeatherForecast(for: invalidLocation)
        #expect(service.error != nil)
    }
    
    // MARK: - Score Color Tests
    
    @Test func testScoreColorRanges() {
        let excellentScore = 85.0
        let goodScore = 65.0
        let poorScore = 45.0
        
        let forecastExcellent = WeatherForecast(
            date: Date(),
            temperatureMin: -4,
            temperatureMax: 0,
            snowfall: 10,
            snowHeight: 50,
            sunshine: 80
        )
        
        let forecastGood = WeatherForecast(
            date: Date(),
            temperatureMin: -2,
            temperatureMax: 2,
            snowfall: 5,
            snowHeight: 30,
            sunshine: 60
        )
        
        let forecastPoor = WeatherForecast(
            date: Date(),
            temperatureMin: 10,
            temperatureMax: 15,
            snowfall: 0,
            snowHeight: 10,
            sunshine: 20
        )
        
        // Test score ranges instead of direct color access
        #expect(forecastExcellent.score >= 80)
        #expect(forecastGood.score >= 60 && forecastGood.score < 80)
        #expect(forecastPoor.score < 60)
    }
}
