import Foundation

@MainActor
class WeatherService: ObservableObject {
    @Published var forecast: [WeatherForecast] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let baseURL = "https://api.open-meteo.com/v1/forecast"
    
    func fetchWeatherForecast(for location: Location) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            var components = URLComponents(string: baseURL)
            components?.queryItems = [
                URLQueryItem(name: "latitude", value: String(location.latitude)),
                URLQueryItem(name: "longitude", value: String(location.longitude)),
                URLQueryItem(name: "daily", value: "temperature_2m_max,snowfall_sum"),
                URLQueryItem(name: "timezone", value: "auto"),
                URLQueryItem(name: "forecast_days", value: "7")
            ]
            
            guard let url = components?.url else {
                throw URLError(.badURL)
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            self.forecast = zip(response.daily.time,
                              zip(response.daily.temperature2mMax,
                                  response.daily.snowfallSum)).compactMap { dateString, values in
                let (temp, snow) = values
                guard let date = dateFormatter.date(from: dateString) else { return nil }
                return WeatherForecast(
                    date: date,
                    temperature: temp,
                    snowfall: snow,
                    snowHeight: snow * 2, // Simplified estimation
                    sunshine: Double.random(in: 0...100) // API doesn't provide sunshine data
                )
            }
        } catch {
            self.error = error
            print("Weather fetch error: \(error.localizedDescription)")
        }
    }
}

// API Response structures
struct WeatherResponse: Codable {
    let daily: DailyData
}

struct DailyData: Codable {
    let time: [String]
    let temperature2mMax: [Double]
    let snowfallSum: [Double]
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature2mMax = "temperature_2m_max"
        case snowfallSum = "snowfall_sum"
    }
} 