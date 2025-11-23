# WeatherApp Setup Guide

## Prerequisites

- iOS 14.0 or later
- Xcode 15.0 or later
- Swift 6.0 or later
- A WeatherAPI.com API key

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/DanD21/WeatherApp.git
   cd WeatherApp
   ```

2. **Set up your API key**

   The app requires a WeatherAPI.com API key. Follow these steps:

   a. Get your API key from [WeatherAPI.com](https://www.weatherapi.com/)

   b. Copy the template file:
      ```bash
      cp WeatherApp/Secrets.template.plist WeatherApp/Secrets.plist
      ```

   c. Open `WeatherApp/Secrets.plist` and replace `YOUR_WEATHER_API_KEY_HERE` with your actual API key

   **IMPORTANT:** The `Secrets.plist` file is gitignored and should never be committed to version control.

3. **Open the project**
   ```bash
   open WeatherApp.xcodeproj
   ```

4. **Build and run**
   - Select your target device or simulator
   - Press ⌘R to build and run

## Features

### Swift 6 Concurrency
- Full adoption of Swift 6 strict concurrency model
- `@MainActor` isolation for UI components
- `Sendable` conformance for data models
- Modern async/await patterns

### Security Improvements
- API keys stored in gitignored `Secrets.plist` file
- Proper URL encoding using `URLComponents`
- Input validation for user-entered city names

### User Experience
- **Pull-to-refresh**: Swipe down to refresh weather data
- **Temperature units**: Toggle between Celsius and Fahrenheit via the toolbar
- **Smart caching**: Weather data cached for 10 minutes to reduce API calls
- **Location services**: Automatic weather for current location
- **Manual search**: Search for any city worldwide
- **Error handling**: Clear error messages for network, location, and API issues

### Accessibility
- VoiceOver support with descriptive labels
- Semantic accessibility traits for all UI elements
- Screen reader friendly navigation

## Troubleshooting

### "Failed to load API key" error
- Ensure you've created `WeatherApp/Secrets.plist` from the template
- Verify the API key is correctly set in the plist file
- Clean build folder (⌘⇧K) and rebuild

### Location not working
- Check that location permissions are granted in Settings
- Ensure you're running on a device with location services enabled
- The app requests "When In Use" location permission

### API errors
- Verify your API key is valid and active
- Check you haven't exceeded the API rate limit
- Ensure you have an internet connection

## Architecture

The app follows the MVVM (Model-View-ViewModel) pattern:

```
Models/
└── Weather.swift          # Codable data models with Sendable conformance

Services/
├── WeatherService.swift   # API networking with proper error handling
└── LocationManager.swift  # Core Location wrapper with @MainActor

ViewModels/
└── WeatherViewModel.swift # Business logic with caching

Views/
├── ContentView.swift      # Main view with search and weather display
└── ForecastView.swift     # Forecast card component

Supporting/
├── WeatherSymbols.swift   # SF Symbol mappings for weather conditions
├── Constants.swift        # Secure API key loading
└── Secrets.plist         # Gitignored API key storage (you create this)
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

**Note:** Never commit your `Secrets.plist` file!

## License

MIT License - See LICENSE file for details
