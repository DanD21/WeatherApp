//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Dan Danilescu on 01.02.2024.
//

import Combine
import Foundation
import CoreLocation
import SwiftUI
import OSLog

enum TemperatureUnit: String, CaseIterable, Identifiable, Codable {
    case celsius = "Celsius"
    case fahrenheit = "Fahrenheit"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
}

@MainActor
final class WeatherViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var weatherData: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchHistory: [String] = []
    @Published var favoriteLocations: [String] = []

    // MARK: - AppStorage for Persistence
    @AppStorage(AppConfiguration.UserDefaultsKeys.temperatureUnit)
    var temperatureUnit: TemperatureUnit = .celsius

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let weatherService = WeatherService()
    let locationManager = LocationManager()
    private let logger = Logger(subsystem: AppConfiguration.subsystem, category: "WeatherViewModel")

    // Persistent cache
    private var persistentCache = WeatherCache()

    // MARK: - Initialization
    init() {
        loadPersistedData()

        // Fetch weather data when location updates
        locationManager.$city
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] city in
                Task { @MainActor in
                    await self?.fetchWeather(forCity: city)
                }
            }
            .store(in: &cancellables)

        // Show location errors
        locationManager.$locationError
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.errorMessage = error
                self?.logger.error("Location error: \(error)")
            }
            .store(in: &cancellables)

        // Load cached weather on init
        loadCachedWeatherIfAvailable()
    }

    // MARK: - Public Methods
    func requestLocation() {
        locationManager.requestLocation()
    }

    func fetchWeather(forCity city: String, forceRefresh: Bool = false) async {
        let cacheKey = city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Check cache first
        if !forceRefresh, let cachedData = persistentCache.get(forKey: cacheKey) {
            logger.info("Using cached weather data for: \(city)")
            weatherData = cachedData
            return
        }

        isLoading = true
        errorMessage = nil
        logger.info("Fetching fresh weather data for: \(city)")

        await withTaskGroup(of: Void.self) { _ in
            weatherService.fetchWeatherData(forCity: city)
                .sink(receiveCompletion: { [weak self] completion in
                    Task { @MainActor in
                        self?.isLoading = false
                        if case let .failure(error) = completion {
                            self?.errorMessage = error.description
                        }
                    }
                }, receiveValue: { [weak self] data in
                    Task { @MainActor in
                        self?.weatherData = data
                        self?.persistentCache.save(data, forKey: cacheKey)
                        self?.addToSearchHistory(city: data.location.name)
                        self?.logger.info("Successfully fetched weather for: \(data.location.name)")
                    }
                })
                .store(in: &cancellables)
        }
    }

    func refreshWeather() async {
        if let city = locationManager.city {
            await fetchWeather(forCity: city, forceRefresh: true)
        } else if let weatherData = weatherData {
            await fetchWeather(forCity: weatherData.location.name, forceRefresh: true)
        }
    }

    func toggleFavorite(city: String) {
        if favoriteLocations.contains(city) {
            favoriteLocations.removeAll { $0 == city }
        } else {
            if favoriteLocations.count >= AppConfiguration.maxFavoriteLocations {
                favoriteLocations.removeFirst()
            }
            favoriteLocations.append(city)
        }
        saveFavorites()
    }

    func isFavorite(city: String) -> Bool {
        favoriteLocations.contains(city)
    }

    func clearSearchHistory() {
        searchHistory.removeAll()
        saveSearchHistory()
    }

    // MARK: - Temperature Conversion
    func temperature(celsius: Double) -> String {
        switch temperatureUnit {
        case .celsius:
            return "\(Int(celsius.rounded()))"
        case .fahrenheit:
            let fahrenheit = celsius * 9/5 + 32
            return "\(Int(fahrenheit.rounded()))"
        }
    }

    func temperatureRange(min: Double, max: Double) -> String {
        switch temperatureUnit {
        case .celsius:
            return "\(Int(min.rounded()))° / \(Int(max.rounded()))°"
        case .fahrenheit:
            let minF = min * 9/5 + 32
            let maxF = max * 9/5 + 32
            return "\(Int(minF.rounded()))° / \(Int(maxF.rounded()))°"
        }
    }

    func formatTemperature(_ celsius: Double) -> String {
        switch temperatureUnit {
        case .celsius:
            return String(format: "%.0f°C", celsius)
        case .fahrenheit:
            let fahrenheit = celsius * 9/5 + 32
            return String(format: "%.0f°F", fahrenheit)
        }
    }

    // MARK: - Private Methods
    private func addToSearchHistory(city: String) {
        // Remove duplicates
        searchHistory.removeAll { $0.lowercased() == city.lowercased() }

        // Add to front
        searchHistory.insert(city, at: 0)

        // Limit history size
        if searchHistory.count > AppConfiguration.maxSearchHistoryItems {
            searchHistory = Array(searchHistory.prefix(AppConfiguration.maxSearchHistoryItems))
        }

        saveSearchHistory()
    }

    private func loadPersistedData() {
        // Load search history
        if let data = UserDefaults.standard.data(forKey: AppConfiguration.UserDefaultsKeys.searchHistory),
           let history = try? JSONDecoder().decode([String].self, from: data) {
            searchHistory = history
        }

        // Load favorites
        if let data = UserDefaults.standard.data(forKey: AppConfiguration.UserDefaultsKeys.favoriteLocations),
           let favorites = try? JSONDecoder().decode([String].self, from: data) {
            favoriteLocations = favorites
        }
    }

    private func saveSearchHistory() {
        if let data = try? JSONEncoder().encode(searchHistory) {
            UserDefaults.standard.set(data, forKey: AppConfiguration.UserDefaultsKeys.searchHistory)
        }
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteLocations) {
            UserDefaults.standard.set(data, forKey: AppConfiguration.UserDefaultsKeys.favoriteLocations)
        }
    }

    private func loadCachedWeatherIfAvailable() {
        // Try to load last viewed weather from cache
        if let lastCity = UserDefaults.standard.string(forKey: AppConfiguration.UserDefaultsKeys.lastSearchedCity),
           let cachedData = persistentCache.get(forKey: lastCity.lowercased()) {
            weatherData = cachedData
            logger.info("Loaded cached weather for last city: \(lastCity)")
        }
    }
}

// MARK: - Weather Cache
private class WeatherCache {
    private let logger = Logger(subsystem: AppConfiguration.subsystem, category: "WeatherCache")

    func save(_ data: WeatherData, forKey key: String) {
        guard let encoded = try? JSONEncoder().encode(data) else {
            logger.error("Failed to encode weather data for caching")
            return
        }

        UserDefaults.standard.set(encoded, forKey: "weather_\(key)")
        UserDefaults.standard.set(Date(), forKey: "weather_timestamp_\(key)")
        UserDefaults.standard.set(data.location.name, forKey: AppConfiguration.UserDefaultsKeys.lastSearchedCity)

        logger.info("Cached weather data for: \(key)")
    }

    func get(forKey key: String) -> WeatherData? {
        guard let data = UserDefaults.standard.data(forKey: "weather_\(key)"),
              let timestamp = UserDefaults.standard.object(forKey: "weather_timestamp_\(key)") as? Date else {
            return nil
        }

        // Check if cache is still valid
        let age = Date().timeIntervalSince(timestamp)
        if age > AppConfiguration.cacheExpirationInterval {
            logger.info("Cache expired for: \(key)")
            return nil
        }

        guard let weatherData = try? JSONDecoder().decode(WeatherData.self, from: data) else {
            logger.error("Failed to decode cached weather data for: \(key)")
            return nil
        }

        return weatherData
    }
}
