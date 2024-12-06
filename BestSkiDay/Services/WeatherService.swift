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
                URLQueryItem(name: "hourly", value: "snow_depth"),
                URLQueryItem(name: "daily", value: "temperature_2m_max,temperature_2m_min,sunshine_duration,snowfall_sum,wind_speed_10m_max"),
                URLQueryItem(name: "timezone", value: "auto"),
                URLQueryItem(name: "models", value: "best_match")
            ]
            
            guard let url = components?.url else {
                throw URLError(.badURL)
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            print("API Response: \(String(data: data, encoding: .utf8) ?? "none")")
            let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            self.forecast = zip(response.daily.time,
                              zip(response.daily.temperature2mMax,
                                  zip(response.daily.snowfallSum,
                                      response.daily.sunshineDuration))).map { dateString, values in
                let (temp, (snowfall, sunshine)) = values
                let date = dateFormatter.date(from: dateString) ?? Date()
                
                // Get average snow depth for the day from hourly data
                let dayIndex = response.daily.time.firstIndex(of: dateString) ?? 0
                let startHour = dayIndex * 24
                let endHour = min(startHour + 24, response.hourly.snowDepth.count)
                let daySnowDepths = Array(response.hourly.snowDepth[startHour..<endHour])
                let avgSnowDepth = daySnowDepths.reduce(0.0, +) / Double(daySnowDepths.count)
                
                // Convert sunshine from seconds to percentage (0-100)
                let sunshinePercentage = min(100, (sunshine / (24 * 3600)) * 100)
                
                return WeatherForecast(
                    date: date,
                    temperatureMin: response.daily.temperature2mMin[dayIndex],
                    temperatureMax: response.daily.temperature2mMax[dayIndex],
                    snowfall: snowfall,
                    snowHeight: avgSnowDepth * 100, // Convert from meters to cm
                    sunshine: sunshinePercentage
                )
            }
        } catch {
            self.error = error
            print("Weather fetch error: \(error)")
        }
    }
}

struct WeatherResponse: Codable {
    let daily: DailyData
    let hourly: HourlyData
}

struct DailyData: Codable {
    let time: [String]
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    let sunshineDuration: [Double]
    let snowfallSum: [Double]
    let windSpeed10mMax: [Double]
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case sunshineDuration = "sunshine_duration"
        case snowfallSum = "snowfall_sum"
        case windSpeed10mMax = "wind_speed_10m_max"
    }
}

struct HourlyData: Codable {
    let time: [String]
    let snowDepth: [Double]
    
    enum CodingKeys: String, CodingKey {
        case time
        case snowDepth = "snow_depth"
    }
} 