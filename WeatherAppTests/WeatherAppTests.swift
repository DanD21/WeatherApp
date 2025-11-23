//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Dan Danilescu on 31.01.2024.
//

import XCTest
@testable import WeatherApp

final class WeatherAppTests: XCTestCase {
    // MARK: - Temperature Conversion Tests

    func testTemperatureConversionCelsius() {
        let viewModel = WeatherViewModel()
        viewModel.temperatureUnit = .celsius

        let result = viewModel.temperature(celsius: 20.0)
        XCTAssertEqual(result, "20", "Celsius temperature should be 20")
    }

    func testTemperatureConversionFahrenheit() {
        let viewModel = WeatherViewModel()
        viewModel.temperatureUnit = .fahrenheit

        let result = viewModel.temperature(celsius: 20.0)
        XCTAssertEqual(result, "68", "20°C should convert to 68°F")
    }

    func testTemperatureRangeCelsius() {
        let viewModel = WeatherViewModel()
        viewModel.temperatureUnit = .celsius

        let result = viewModel.temperatureRange(min: 15.0, max: 25.0)
        XCTAssertEqual(result, "15° / 25°", "Temperature range should be formatted correctly in Celsius")
    }

    func testTemperatureRangeFahrenheit() {
        let viewModel = WeatherViewModel()
        viewModel.temperatureUnit = .fahrenheit

        let result = viewModel.temperatureRange(min: 15.0, max: 25.0)
        XCTAssertEqual(result, "59° / 77°", "Temperature range should be formatted correctly in Fahrenheit")
    }

    // MARK: - Favorites Management Tests

    func testToggleFavorite() {
        let viewModel = WeatherViewModel()
        let cityName = "London"

        XCTAssertFalse(viewModel.isFavorite(city: cityName), "City should not be favorite initially")

        viewModel.toggleFavorite(city: cityName)
        XCTAssertTrue(viewModel.isFavorite(city: cityName), "City should be added to favorites")

        viewModel.toggleFavorite(city: cityName)
        XCTAssertFalse(viewModel.isFavorite(city: cityName), "City should be removed from favorites")
    }

    func testFavoritesLimit() {
        let viewModel = WeatherViewModel()
        let cities = ["City1", "City2", "City3", "City4", "City5", "City6"]

        for city in cities {
            viewModel.toggleFavorite(city: city)
        }

        XCTAssertEqual(viewModel.favoriteLocations.count, AppConfiguration.maxFavoriteLocations,
                      "Favorites should not exceed maximum limit")
        XCTAssertFalse(viewModel.favoriteLocations.contains("City1"),
                      "First city should be removed when limit is exceeded")
        XCTAssertTrue(viewModel.favoriteLocations.contains("City6"),
                     "Latest city should be in favorites")
    }

    // MARK: - Search History Tests

    func testClearSearchHistory() {
        let viewModel = WeatherViewModel()
        viewModel.searchHistory = ["London", "Paris", "Tokyo"]

        viewModel.clearSearchHistory()
        XCTAssertTrue(viewModel.searchHistory.isEmpty, "Search history should be empty after clearing")
    }

    // MARK: - Weather Data Model Tests

    func testWeatherDataDecoding() throws {
        let json = """
        {
            "location": {
                "name": "London",
                "region": "City of London, Greater London",
                "country": "United Kingdom",
                "lat": 51.52,
                "lon": -0.11,
                "tz_id": "Europe/London",
                "localtime_epoch": 1706745600,
                "localtime": "2024-02-01 10:00"
            },
            "current": {
                "temp_c": 10.0,
                "temp_f": 50.0,
                "feelslike_c": 8.0,
                "feelslike_f": 46.4,
                "humidity": 75,
                "wind_kph": 15.5,
                "wind_mph": 9.6,
                "wind_dir": "NW",
                "pressure_mb": 1015.0,
                "precip_mm": 0.0,
                "uv": 3.0,
                "vis_km": 10.0,
                "condition": {
                    "text": "Partly cloudy",
                    "icon": "//cdn.weatherapi.com/weather/64x64/day/116.png",
                    "code": 1003
                }
            },
            "forecast": {
                "forecastday": [
                    {
                        "date": "2024-02-01",
                        "date_epoch": 1706745600,
                        "day": {
                            "maxtemp_c": 12.0,
                            "mintemp_c": 8.0,
                            "maxtemp_f": 53.6,
                            "mintemp_f": 46.4,
                            "avgtemp_c": 10.0,
                            "avgtemp_f": 50.0,
                            "maxwind_kph": 20.0,
                            "totalprecip_mm": 0.0,
                            "avghumidity": 70,
                            "daily_chance_of_rain": 10,
                            "daily_chance_of_snow": 0,
                            "uv": 3.0,
                            "condition": {
                                "text": "Partly cloudy",
                                "icon": "//cdn.weatherapi.com/weather/64x64/day/116.png",
                                "code": 1003
                            }
                        },
                        "astro": {
                            "sunrise": "07:30 AM",
                            "sunset": "05:00 PM",
                            "moonrise": "08:00 PM",
                            "moonset": "09:00 AM",
                            "moon_phase": "Waxing Gibbous"
                        }
                    }
                ]
            }
        }
        """

        let data = json.data(using: .utf8)!
        let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)

        XCTAssertEqual(weatherData.location.name, "London")
        XCTAssertEqual(weatherData.current.temp_c, 10.0)
        XCTAssertEqual(weatherData.current.humidity, 75)
        XCTAssertEqual(weatherData.forecast.forecastday.count, 1)
        XCTAssertEqual(weatherData.forecast.forecastday[0].day.maxtemp_c, 12.0)
    }

    // MARK: - Weather Service Error Tests

    func testWeatherServiceErrorDescriptions() {
        XCTAssertEqual(WeatherServiceError.networkError.description,
                      "No internet connection. Please check your network and try again.")
        XCTAssertEqual(WeatherServiceError.apiLimitReached.description,
                      "API request limit reached. Please try again later.")
        XCTAssertEqual(WeatherServiceError.invalidCityName.description,
                      "Invalid city name. Please enter a valid city.")
        XCTAssertEqual(WeatherServiceError.httpError(404).description,
                      "Server error (code: 404). Please try again.")
    }

    // MARK: - Temperature Unit Tests

    func testTemperatureUnitSymbols() {
        XCTAssertEqual(TemperatureUnit.celsius.symbol, "°C")
        XCTAssertEqual(TemperatureUnit.fahrenheit.symbol, "°F")
    }

    func testTemperatureUnitIdentifiable() {
        XCTAssertEqual(TemperatureUnit.celsius.id, "Celsius")
        XCTAssertEqual(TemperatureUnit.fahrenheit.id, "Fahrenheit")
    }

    // MARK: - Configuration Tests

    func testAppConfigurationConstants() {
        XCTAssertEqual(AppConfiguration.forecastDays, 3)
        XCTAssertEqual(AppConfiguration.maxSearchHistoryItems, 10)
        XCTAssertEqual(AppConfiguration.maxFavoriteLocations, 5)
        XCTAssertGreaterThan(AppConfiguration.cacheExpirationInterval, 0)
    }
}
