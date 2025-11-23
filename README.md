# Weather Forecast App

## Overview
A modern iOS weather application built with **Swift 6** and **SwiftUI**, providing real-time weather information and 3-day forecasts. The app features location-based weather, city search, temperature unit conversion, and comprehensive accessibility support.

## ✨ Features

### Core Functionality
- **Current Weather Information**: Real-time temperature, conditions, and location
- **Detailed Weather View**: Tap weather card for comprehensive details including hourly forecast
- **3-Day Weather Forecast**: Detailed forecast with conditions and temperature ranges
- **Hourly Forecast**: 24-hour weather predictions with precipitation chances
- **Extended Weather Data**: Humidity, wind speed/direction, UV index, visibility, pressure
- **Location-Based Results**: Automatic weather updates for your current location
- **Smart City Search**: Search with autocomplete and search history
- **Pull-to-Refresh**: Swipe down to update weather data

### Modern Swift 6
- ✅ Full Swift 6 strict concurrency support
- ✅ `@MainActor` isolation for thread-safe UI updates
- ✅ `Sendable` conformance for all data models
- ✅ Modern async/await patterns
- ✅ Type-safe error handling

### User Experience
- 🌡️ **Temperature Unit Toggle**: Switch between Celsius and Fahrenheit (persisted)
- ⭐ **Favorites**: Save up to 5 favorite locations for quick access
- 🕐 **Search History**: Auto-complete with recent searches
- 💾 **Persistent Caching**: Weather data cached and persists across app launches
- ♿ **Full Accessibility**: VoiceOver support with descriptive labels
- 🎨 **Modern UI**: Clean interface with SF Symbols and color-coded conditions
- 🔒 **Secure**: API keys properly secured and never committed
- 📊 **Quick Stats**: At-a-glance humidity, wind, and UV index
- 🌅 **Astronomical Data**: Sunrise, sunset, moon phase information

### Enhanced Error Handling
- Network connectivity errors
- Location permission management
- Invalid city name validation
- API rate limit handling
- Proper HTTP status code responses

## Requirements
- iOS 14.0+
- Xcode 15.0+
- Swift 6.0+
- WeatherAPI.com API key

## Installation

See [SETUP.md](SETUP.md) for detailed setup instructions.

**Quick Start:**
1. Clone the repository
   ```bash
   git clone https://github.com/DanD21/WeatherApp.git
   cd WeatherApp
   ```
2. Copy `WeatherApp/Secrets.template.plist` to `WeatherApp/Secrets.plist`
3. Add your WeatherAPI.com API key to `Secrets.plist`
4. Open `WeatherApp.xcodeproj` in Xcode
5. Build and run

## Usage

### First Launch
1. Grant location permission when prompted
2. Weather for your current location loads automatically

### Features
- **Search**: Enter any city name in the search field
- **Refresh**: Pull down to refresh weather data
- **Temperature Units**: Tap the thermometer icon to switch between °C and °F
- **Accessibility**: Full VoiceOver support for visually impaired users

## Technology Stack

- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive programming for data flow
- **Core Location** - GPS and location services
- **Swift 6** - Latest Swift with strict concurrency
- **Async/Await** - Modern asynchronous programming

## API
The app uses [WeatherAPI.com](https://www.weatherapi.com/) for weather data. Get your free API key at their website.

## Architecture

**MVVM Pattern** with clean separation of concerns:
- **Models**: Sendable Codable structs for type-safe data
- **Services**: WeatherService (networking) & LocationManager (GPS)
- **ViewModels**: WeatherViewModel with caching and state management
- **Views**: SwiftUI views with accessibility support

## Security

- ✅ API keys stored in gitignored `Secrets.plist`
- ✅ Proper URL encoding prevents injection attacks
- ✅ Input validation for user-entered data
- ✅ No sensitive data in source code

## What's New in this Version

### Swift 6 Modernization
- Migrated to Swift 6 strict concurrency model
- Added `@MainActor` isolation for UI components
- Implemented `Sendable` conformance throughout
- Converted to async/await patterns

### Security Improvements
- Moved API keys to secure, gitignored storage
- Fixed URL encoding vulnerability
- Added comprehensive input validation

### Features Added (Latest Update)
- ⭐ **Favorites system** - Save up to 5 favorite locations
- 🕐 **Search history** - Auto-complete with recent searches
- 📊 **Extended weather data** - Humidity, wind, UV, pressure, visibility, "feels like" temperature
- 🌅 **Astronomical data** - Sunrise, sunset, moonrise, moonset, moon phase
- ⏰ **Hourly forecast** - 24-hour detailed predictions
- 💾 **Persistent cache** - Weather data persists across app launches
- 🎯 **Detailed weather view** - Tap for comprehensive weather information
- 📝 **OSLog integration** - Better debugging and error tracking
- ⚡ **Performance optimizations** - Static DateFormatter instances
- 🔧 **Configuration system** - Centralized app constants
- ✅ **Unit tests** - Comprehensive test coverage
- 🎨 **UI enhancements** - Search suggestions dropdown, quick stats cards
- 🔍 **Search debouncing** - Prevents rapid API calls

### Previous Features
- Temperature unit toggle (Celsius/Fahrenheit) with persistence
- Pull-to-refresh functionality
- Smart weather data caching
- Enhanced location permission handling
- Full VoiceOver accessibility support
- Modern, cleaner UI design
- Better error messages
- Welcome screen for first-time users
- Loading states and progress indicators

## Contributing
Contributions to the Weather Forecast App are welcome. Please consider the following steps:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature-xyz`).
3. Make your changes.
4. Commit your changes (`git commit -am 'Add some feature'`).
5. Push to the branch (`git push origin feature-xyz`).
6. Create a new Pull Request.

**Note:** Never commit `Secrets.plist` - always use the template!

## License
MIT

## Contact
Dan Danilescu – [dan.danilescu@gmail.com](mailto:dan.danilescu@gmail.com)

GitHub: [https://github.com/DanD21](https://github.com/DanD21)
