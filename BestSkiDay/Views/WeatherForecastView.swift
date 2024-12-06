import SwiftUI
import CoreLocation
import CoreLocationUI

struct WeatherForecastView: View {
    let location: Location
    @StateObject private var weatherService = WeatherService()
    @State private var showingLocationPicker = false
    @State private var currentLocation: Location
    
    init(location: Location) {
        self.location = location
        self._currentLocation = State(initialValue: location)
    }
    
    var body: some View {
        Group {
            if weatherService.isLoading {
                ProgressView("Loading forecast...")
            } else if let error = weatherService.error {
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
                            await weatherService.fetchWeatherForecast(for: currentLocation)
                        }
                    }
                }
                .padding()
            } else {
                VStack {
                    HStack {
                        Text(currentLocation.name)
                            .font(.headline)
                        Spacer()
                        LocationButton(.currentLocation) {
                            showingLocationPicker = true
                        }
                        .labelStyle(.iconOnly)
                        .cornerRadius(6)
                        .frame(width: 32, height: 32)
                    }
                    .padding(.horizontal)
                    
                    List(weatherService.forecast) { day in
                        ForecastRow(forecast: day)
                    }
                }
            }
        }
        .task(id: currentLocation.id) {
            await weatherService.fetchWeatherForecast(for: currentLocation)
        }
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView(currentLocation: currentLocation) { newLocation in
                currentLocation = newLocation
                showingLocationPicker = false
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
                Text(forecast.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                Spacer()
                CircularScoreView(score: forecast.score, color: scoreColor)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Label("\(Int(forecast.snowfall))cm", systemImage: "snow")
                    Label("\(Int(forecast.snowHeight))cm", systemImage: "mountain.2")
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Label("\(Int(forecast.temperature))°C", systemImage: "thermometer")
                    Label("\(Int(forecast.sunshine))%", systemImage: "sun.max")
                }
            }
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let mockLocation = Location(name: "Test Location", coordinate: CLLocationCoordinate2D(latitude: 47.0, longitude: 10.0))
    return WeatherForecastView(location: mockLocation)
} 