//
//  Weather.swift
//  WeatherApp
//
//  Created by Dan Danilescu on 31.01.2024.
//

import Foundation

struct WeatherData: Codable, Sendable {
    let location: Location
    let current: CurrentWeather
    let forecast: Forecast
}

struct Location: Codable, Sendable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let tz_id: String
    let localtime_epoch: Int
    let localtime: String
}

struct CurrentWeather: Codable, Sendable {
    let temp_c: Double
    let temp_f: Double
    let feelslike_c: Double
    let feelslike_f: Double
    let humidity: Int
    let wind_kph: Double
    let wind_mph: Double
    let wind_dir: String
    let pressure_mb: Double
    let precip_mm: Double
    let uv: Double
    let vis_km: Double
    let condition: WeatherCondition
}

struct WeatherCondition: Codable, Sendable {
    let text: String
    let icon: String
    let code: Int
}

struct Forecast: Codable, Sendable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable, Identifiable, Sendable {
    var id: String { date }
    let date: String
    let date_epoch: Int
    let day: Day
    let hour: [HourlyWeather]?
    let astro: Astro
}

struct HourlyWeather: Codable, Identifiable, Sendable {
    var id: Int { time_epoch }
    let time_epoch: Int
    let time: String
    let temp_c: Double
    let temp_f: Double
    let condition: WeatherCondition
    let wind_kph: Double
    let wind_dir: String
    let precip_mm: Double
    let humidity: Int
    let feelslike_c: Double
    let feelslike_f: Double
    let chance_of_rain: Int
}

struct Astro: Codable, Sendable {
    let sunrise: String
    let sunset: String
    let moonrise: String
    let moonset: String
    let moon_phase: String
}

struct Day: Codable, Sendable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let maxtemp_f: Double
    let mintemp_f: Double
    let avgtemp_c: Double
    let avgtemp_f: Double
    let maxwind_kph: Double
    let totalprecip_mm: Double
    let avghumidity: Int
    let daily_chance_of_rain: Int
    let daily_chance_of_snow: Int
    let uv: Double
    let condition: WeatherCondition
}

