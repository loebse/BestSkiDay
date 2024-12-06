import Foundation

struct WeatherForecast: Identifiable {
    let id = UUID()
    let date: Date
    let temperatureMin: Double
    let temperatureMax: Double
    let snowfall: Double
    let snowHeight: Double
    let sunshine: Double
    
    var score: Double {
        // Calculate score based on conditions
        // Normalize each component to 0-100 scale
        let avgTemp = (temperatureMax + temperatureMin) / 2
        let temperatureScore = max(0, min(100, (20 - abs(avgTemp + 2)) * 5)) // Best around -2°C
        let snowScore = min(100, (snowfall * 10) + (snowHeight * 0.5)) // More snow is better
        let sunScore = sunshine // Already 0-100
        
        // Weight the components
        return (temperatureScore * 0.3) + (snowScore * 0.4) + (sunScore * 0.3)
    }
} 