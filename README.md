# Best Ski Day

![appstoreicon](BestSkiDay/Assets.xcassets/AppIcon.appiconset/AppIcon~ios-marketing%201.png)

Best Ski Day is an iOS app that helps winter sports enthusiasts find the perfect day for skiing within the next week. By analyzing various weather conditions, it calculates a "ski score" for each day to help you plan your perfect ski trip.

## Features

- **Weather-Based Scoring**: Combines multiple factors to calculate the best skiing conditions:
  - Temperature (optimal around -2°C)
  - Snowfall amount
  - Snow height
  - Sunshine percentage

- **Location Services**:
  - Use your current location
  - Search for any ski destination
  - Save favorite locations
  - Quick access to recent locations
  - Swipe actions for managing favorites

- **7-Day Forecast**:
  - Daily weather predictions
  - Visual score indicator
  - Detailed weather metrics
  - Easy-to-read interface

## How It Works

The app uses a sophisticated scoring system that weighs different weather conditions:
- 40% Snow conditions (fresh snowfall and base height)
- 30% Temperature (optimal skiing temperature)
- 30% Sunshine (visibility and comfort)

Each day receives a score from 0-100:
- 🟢 80-100: Excellent conditions
- 🟡 60-79: Good conditions
- 🔴 0-59: Suboptimal conditions

## Location Management

The app provides several ways to manage your ski destinations:
- **Current Location**: Automatically detect your location
- **Search**: Find any ski resort or location worldwide
- **Favorites**: Save and organize your preferred destinations
  - Add to favorites with a single tap
  - Quick access to favorite locations
  - Swipe to remove from favorites
  - Persistent storage between app launches

## Privacy

Best Ski Day requires location access to provide accurate weather forecasts. Your location data is only used to fetch weather information and is never stored or shared with third parties. Favorite locations are stored locally on your device.

## Requirements

- iOS 15.0 or later
- Location Services enabled for current location features
- Internet connection for weather data

## Data Sources

Weather data is provided by the Open-Meteo API, offering reliable and up-to-date forecasts for locations worldwide.

## Future Development

Check out our [Roadmap](ROADMAP.md) to see what features and improvements are planned for future releases. The roadmap includes short-term, medium-term, and long-term goals for enhancing the app's functionality and user experience.

## Feedback

Found a bug or have a feature request? Please open an issue in this repository.
