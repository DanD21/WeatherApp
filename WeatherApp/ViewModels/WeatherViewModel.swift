//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Dan Danilescu on 01.02.2024.
//

import Combine
import Foundation
import CoreLocation

enum TemperatureUnit: String, CaseIterable, Identifiable {
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
    @Published var weatherData: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var temperatureUnit: TemperatureUnit = .celsius

    private var cancellables = Set<AnyCancellable>()
    private let weatherService = WeatherService()
    let locationManager = LocationManager()

    // Simple cache
    private struct CachedWeather {
        let data: WeatherData
        let timestamp: Date
    }
    private var weatherCache: [String: CachedWeather] = [:]
    private let cacheExpirationInterval: TimeInterval = 600 // 10 minutes

    init() {
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
            }
            .store(in: &cancellables)
    }

    func requestLocation() {
        locationManager.requestLocation()
    }

    func fetchWeather(forCity city: String, forceRefresh: Bool = false) async {
        let cacheKey = city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Check cache first
        if !forceRefresh,
           let cached = weatherCache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < cacheExpirationInterval {
            weatherData = cached.data
            return
        }

        isLoading = true
        errorMessage = nil

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
                        self?.weatherCache[cacheKey] = CachedWeather(
                            data: data,
                            timestamp: Date()
                        )
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
}
