//
//  Weather.swift
//  WeatherApp
//
//  Created by Dan Danilescu on 31.01.2024.
//

import Foundation

struct WeatherData: Codable {
    let location: Location
    let current: CurrentWeather
    let forecast: Forecast
}

struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let tz_id: String
    let localtime_epoch: Int
    let localtime: String
}

struct CurrentWeather: Codable {
    let temp_c: Double
    let condition: WeatherCondition
}

struct WeatherCondition: Codable {
    let text: String
    let icon: String
    let code: Int
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable, Identifiable {
    var id: String { date }
    let date: String
    let day: Day
}

struct Day: Codable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let condition: WeatherCondition
}

