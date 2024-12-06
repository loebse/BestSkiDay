import SwiftUI
import CoreLocation
import CoreLocationUI

struct WeatherForecastView: View {
    let location: Location
    @StateObject private var weatherService = WeatherService()
    @State private var showingLocationPicker = false
    @State private var currentLocation: Location
    @State private var isLocationPickerLoading = false
    
    init(location: Location) {
        self.location = location
        self._currentLocation = State(initialValue: location)
    }
    
    var body: some View {
        Group {
            if weatherService.isLoading {
                ProgressView("Loading forecast...")
                    .transition(.opacity)
            } else if let error = weatherService.error {
                ErrorView(error: error) {
                    await weatherService.fetchWeatherForecast(for: currentLocation)
                }
                .transition(.opacity)
            } else {
                VStack {
                    HStack {
                        Text(currentLocation.name)
                            .font(.headline)
                        Spacer()
                        LocationButton(.currentLocation) {
                            isLocationPickerLoading = true
                            showingLocationPicker = true
                        }
                        .labelStyle(.iconOnly)
                        .cornerRadius(6)
                        .frame(width: 32, height: 32)
                        .disabled(isLocationPickerLoading)
                        .opacity(isLocationPickerLoading ? 0.5 : 1)
                    }
                    .padding(.horizontal)
                    
                    List(weatherService.forecast) { day in
                        ForecastRow(forecast: day)
                    }
                    .refreshable {
                        await weatherService.fetchWeatherForecast(for: currentLocation)
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.default, value: weatherService.isLoading)
        .animation(.default, value: weatherService.error != nil)
        .task(id: currentLocation.id) {
            await weatherService.fetchWeatherForecast(for: currentLocation)
        }
        .sheet(isPresented: $showingLocationPicker, onDismiss: {
            isLocationPickerLoading = false
        }) {
            LocationPickerView(currentLocation: currentLocation) { newLocation in
                Task {
                    currentLocation = newLocation
                    showingLocationPicker = false
                    await weatherService.fetchWeatherForecast(for: newLocation)
                }
            }
        }
    }
}

struct CircularScoreView: View {
    let score: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    color.opacity(0.2),
                    lineWidth: 4
                )
            Circle()
                .trim(from: 0, to: score / 100)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            Text("\(Int(score))%")
                .font(.system(.subheadline, design: .rounded))
                .bold()
                .foregroundColor(color)
                .accessibilityLabel("Score: \(Int(score)) percent")
        }
        .frame(width: 44, height: 44)
    }
}

struct ForecastRow: View {
    let forecast: WeatherForecast
    
    private var scoreColor: Color {
        switch forecast.score {
        case 80...: return .green
        case 60...: return .yellow
        default: return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(forecast.date.formatted(date: .complete, time: .omitted))
                    .font(.headline)
                Spacer()
                CircularScoreView(score: forecast.score, color: scoreColor)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Label("\(Int(forecast.snowfall))cm", systemImage: "snow")
                        .accessibilityLabel("Snowfall: \(Int(forecast.snowfall)) centimeters")
                    Label("\(Int(forecast.snowHeight))cm", systemImage: "mountain.2")
                        .accessibilityLabel("Snow height: \(Int(forecast.snowHeight)) centimeters")
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    HStack(spacing: 12) {
                        Label("\(Int(forecast.temperatureMin))°", systemImage: "thermometer.low")
                        Label("\(Int(forecast.temperatureMax))°", systemImage: "thermometer.high")
                    }
                    Label("\(Int(forecast.sunshine))%", systemImage: "sun.max")
                }
            }
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct ErrorView: View {
    let error: Error
    let retryAction: () async -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            Text("Failed to load forecast")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundColor(.secondary)
            Button("Retry") {
                Task {
                    await retryAction()
                }
            }
        }
        .padding()
    }
}

#Preview {
    let mockLocation = Location(name: "Test Location", coordinate: CLLocationCoordinate2D(latitude: 47.0, longitude: 10.0))
    return WeatherForecastView(location: mockLocation)
} 