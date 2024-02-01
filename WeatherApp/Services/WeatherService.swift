//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Dan Danilescu on 31.01.2024.
//

import Combine
import Foundation

enum WeatherServiceError: Error, CustomStringConvertible {
    case networkError
    case apiLimitReached
    case other(Error)

    var description: String {
        switch self {
        case .networkError:
            return "No internet connection."
        case .apiLimitReached:
            return "API limit reached."
        case .other(let error):
            return error.localizedDescription
        }
    }
}

class WeatherService {
    func fetchWeatherData(forCity city: String) -> AnyPublisher<WeatherData, WeatherServiceError> {
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(Constants.weatherAPIKey)&q=\(city)&days=3&aqi=no&alerts=no"
        guard let url = URL(string: urlString) else {
            return Fail(error: WeatherServiceError.other(URLError(.badURL))).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { error in
                if error.code == .notConnectedToInternet {
                    return WeatherServiceError.networkError
                } else if error.localizedDescription.contains("429") {
                    return WeatherServiceError.apiLimitReached
                } else {
                    return WeatherServiceError.other(error)
                }
            }
            .map(\.data)
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .mapError(WeatherServiceError.other)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
