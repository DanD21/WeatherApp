//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Dan Danilescu on 31.01.2024.
//

import Combine
import Foundation
import OSLog

enum WeatherServiceError: Error, CustomStringConvertible, Sendable {
    case networkError
    case apiLimitReached
    case invalidCityName
    case invalidURL
    case invalidResponse
    case decodingError
    case httpError(Int)
    case other(String)

    var description: String {
        switch self {
        case .networkError:
            return "No internet connection. Please check your network and try again."
        case .apiLimitReached:
            return "API request limit reached. Please try again later."
        case .invalidCityName:
            return "Invalid city name. Please enter a valid city."
        case .invalidURL:
            return "Unable to create request. Please try again."
        case .invalidResponse:
            return "Invalid response from server."
        case .decodingError:
            return "Unable to process weather data."
        case .httpError(let code):
            return "Server error (code: \(code)). Please try again."
        case .other(let message):
            return message
        }
    }
}

final class WeatherService: Sendable {
    private let urlSession: URLSession
    private let logger = Logger(subsystem: AppConfiguration.subsystem, category: "WeatherService")

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func fetchWeatherData(forCity city: String) -> AnyPublisher<WeatherData, WeatherServiceError> {
        // Validate input
        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCity.isEmpty else {
            return Fail(error: WeatherServiceError.invalidCityName).eraseToAnyPublisher()
        }

        // Build URL safely with URLComponents
        var components = URLComponents(string: "https://api.weatherapi.com/v1/forecast.json")
        components?.queryItems = [
            URLQueryItem(name: "key", value: Constants.weatherAPIKey),
            URLQueryItem(name: "q", value: trimmedCity),
            URLQueryItem(name: "days", value: String(AppConfiguration.forecastDays)),
            URLQueryItem(name: "aqi", value: "no"),
            URLQueryItem(name: "alerts", value: "no")
        ]

        logger.info("Fetching weather data for city: \(trimmedCity)")

        guard let url = components?.url else {
            return Fail(error: WeatherServiceError.invalidURL).eraseToAnyPublisher()
        }

        return urlSession.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw WeatherServiceError.invalidResponse
                }

                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 400:
                    throw WeatherServiceError.invalidCityName
                case 429:
                    throw WeatherServiceError.apiLimitReached
                default:
                    throw WeatherServiceError.httpError(httpResponse.statusCode)
                }
            }
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .mapError { [logger] error -> WeatherServiceError in
                if let weatherError = error as? WeatherServiceError {
                    logger.error("Weather API error: \(weatherError.description)")
                    return weatherError
                } else if let urlError = error as? URLError {
                    logger.error("Network error: \(urlError.localizedDescription)")
                    if urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost {
                        return .networkError
                    }
                    return .other(urlError.localizedDescription)
                } else if let decodingError = error as? DecodingError {
                    logger.error("Decoding error: \(String(describing: decodingError))")
                    return .decodingError
                } else {
                    logger.error("Unknown error: \(error.localizedDescription)")
                    return .other(error.localizedDescription)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
