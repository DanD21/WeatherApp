# Weather Forecast App

## Overview
Weather Forecast is an iOS application that provides real-time weather information and forecasts. Utilizing Core Location, it fetches weather data for the user's current location or a city of their choice. The app displays the current weather, temperature, and a 3-day forecast.

## Features
- **Current Weather Information**: Displays temperature, weather condition, and location name.
- **3-Day Weather Forecast**: Shows the forecast for the next three days, including weather conditions and high/low temperatures.
- **Location-Based Results**: Automatically fetches weather data based on the user's current location.
- **Search Functionality**: Allows users to manually enter a city name to get weather data for that location.
- **Error Handling**: Basic handling for common errors like no internet connection or API limit reached.
- **Elegant UI**: Features a user-friendly interface with loading indicators and large, easy-to-read displays.

## Requirements
- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+

## Installation
Clone the repository:
git clone https://github.com/DanD21/WeatherForecastApp.git

Navigate to the project directory and open `WeatherForecastApp.xcodeproj` in Xcode.

## Usage
Upon launching the app, it will request permission to access the device's location. After granting permission, the app will display weather data for the current location. Users can also enter a different city name to get weather information for that location.

## Dependencies
- [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- [Combine](https://developer.apple.com/documentation/combine)
- [Core Location](https://developer.apple.com/documentation/corelocation)

## API Reference
The app uses the [WeatherAPI](https://www.weatherapi.com/) to fetch weather data. An API key is required to access WeatherAPI services.

## Screenshots
(Add screenshots of your app here)

## Contributing
Contributions to the Weather Forecast App are welcome. Please consider the following steps:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature-xyz`).
3. Make your changes.
4. Commit your changes (`git commit -am 'Add some feature'`).
5. Push to the branch (`git push origin feature-xyz`).
6. Create a new Pull Request.

## License
MIT


## Contact
Your Name – [dan.danilescu@gmail.com](mailto:dan.danilescu@gmail.com)

GitHub: [https://github.com/DanD21](https://github.com/DanD21)

