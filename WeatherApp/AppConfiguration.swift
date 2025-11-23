//
//  AppConfiguration.swift
//  WeatherApp
//
//  Configuration constants for the weather application
//

import Foundation

enum AppConfiguration {
    // MARK: - Cache Configuration
    static let cacheExpirationInterval: TimeInterval = 600 // 10 minutes
    static let offlineCacheExpirationInterval: TimeInterval = 3600 // 1 hour for offline data

    // MARK: - API Configuration
    static let forecastDays = 3
    static let requestTimeout: TimeInterval = 30

    // MARK: - Search Configuration
    static let searchDebounceInterval: TimeInterval = 0.5 // 500ms
    static let maxSearchHistoryItems = 10
    static let maxFavoriteLocations = 5

    // MARK: - UserDefaults Keys
    enum UserDefaultsKeys {
        static let temperatureUnit = "temperatureUnit"
        static let lastSearchedCity = "lastSearchedCity"
        static let searchHistory = "searchHistory"
        static let favoriteLocations = "favoriteLocations"
        static let weatherCache = "weatherCache"
        static let cacheTimestamps = "cacheTimestamps"
    }

    // MARK: - Logging
    static let subsystem = "com.weatherapp"
    static let logCategory = "WeatherApp"
}
