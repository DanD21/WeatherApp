//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Dan Danilescu on 01.02.2024.
//

import Combine
import Foundation
import CoreLocation

class WeatherViewModel: ObservableObject {
    @Published var weatherData: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let weatherService = WeatherService()
    private let locationManager = LocationManager()
    
    init() {
        // Fetch weather data when location updates
        locationManager.$city
            .compactMap { $0 }
            .sink { [weak self] city in
                self?.fetchWeather(forCity: city)
            }
            .store(in: &cancellables)
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func fetchWeather(forCity city: String) {
        isLoading = true
        errorMessage = nil
        weatherService.fetchWeatherData(forCity: city)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.description
                }
            }, receiveValue: { [weak self] data in
                self?.weatherData = data
            })
            .store(in: &cancellables)
    }
}
